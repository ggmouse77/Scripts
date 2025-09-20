#!/bin/bash
# RHEL 8.6 -> RHEL 8.10 로컬 레포 업데이트 스크립트
#  1) /usr/local 이 심볼릭 링크면 제거 후 /usr/local.org → /usr/local 교체
#  2) /home/repo/*.rpm 일괄 설치/업데이트 (외부 레포 비활성화)
#  3) 업데이트된 커널(고정 버전)의 usb-storage.ko.xz 삭제 후 dracut 재생성
#  4) yum repo 파일 고정된 내용으로 /etc/yum.repos.d/rhel.repo 작성
#  5) 로그: /home/update.log (누적), 사전 패키지 목록: /home/preinstalled.log (덮어쓰기)

PKG_DIR="/home/repo"
LOG="/home/update.log"
PREINST_LOG="/home/preinstalled.log"
NEW_KERNEL="4.18.0-553.16.1.el8_10.x86_64"

{
  echo "==== [START] $(date -Is) ===="

  # 0) /usr/local 심볼릭 링크 교체 처리
  if [ -L /usr/local ]; then
    echo "[INFO] /usr/local is symlink → replacing with /usr/local.org"
    rm -f /usr/local
    mv /usr/local.org /usr/local
  else
    echo "[INFO] /usr/local is normal directory → no change"
  fi

  # 1) 사전 설치된 패키지 목록 저장 (매번 덮어쓰기)
  rpm -qa | sort > "$PREINST_LOG"

  # 2) 로컬 패키지 업데이트
  echo "--- dnf localinstall start ---"
  RPMs=( "$PKG_DIR"/*.rpm )
  dnf -y --disablerepo='*' localinstall "${RPMs[@]}"
  RC=$?
  echo "--- dnf localinstall end rc=${RC} ---"

  # 3) 업데이트 성공 시 usb-storage 모듈 제거 + initramfs 재생성
  if [ $RC -eq 0 ]; then
    MOD_FILE="/lib/modules/${NEW_KERNEL}/kernel/drivers/usb/storage/usb-storage.ko.xz"
    if [ -f "$MOD_FILE" ]; then
      echo "[INFO] removing $MOD_FILE"
      rm -f "$MOD_FILE"
      echo "[INFO] dracut -f /boot/initramfs-${NEW_KERNEL}.img ${NEW_KERNEL}"
      dracut -f "/boot/initramfs-${NEW_KERNEL}.img" "${NEW_KERNEL}"
    else
      echo "[WARN] $MOD_FILE not found"
    fi

    # 4) repo 파일 고정 내용으로 작성 (덮어쓰기)
    cat <<EOF > /etc/yum.repos.d/rhel.repo
[RHEL8-BaseOS]
name=RHEL8-BaseOS
baseurl=file:///user/svrauto/SA/OS/rhel-8-for-x86_64-baseos-rpms
enabled=0
gpgcheck=0

[RHEL8-AppStream]
name=RHEL8-AppStream
baseurl=file:///user/svrauto/SA/OS/rhel-8-for-x86_64-appstream-rpms
enabled=0
gpgcheck=0

[extra8]
name=extra8
baseurl=file:///user/svrauto/SA/OS/extra8
enabled=0
gpgcheck=0
EOF
    echo "[INFO] /etc/yum.repos.d/rhel.repo created"
  fi

  echo "==== [END]   $(date -Is) rc=${RC} ===="
  exit $RC
} >>"$LOG" 2>&1
