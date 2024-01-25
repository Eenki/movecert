#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in post-fs-data mode

# If you for some reason do not want all your certificates moved from the user store to the system store, you can specify which certificates to move by replacing the * with the name of the certificate; i.e.,

# mv -f /data/misc/user/0/cacerts-added/12abc345.0 $MODDIR/system/etc/security/cacerts

cp -f /data/misc/user/0/cacerts-added/* $MODDIR/system/etc/security/cacerts

[ "$(getenforce)" = "Enforcing" ] || exit 0
A14CA_PATH=/apex/com.android.conscrypt/cacerts
if [ -d "$A14CA_PATH" ]; then
    #Support Android 14, Thanks https://weibo.com/3322982490/Ni21tFiR9
    CA_TMP_DIR=/data/local/tmp/cacerts
    rm -rf "$CA_TMP_DIR"
    mkdir -p -m 700 "$CA_TMP_DIR"
    mount -t tmpfs tmpfs "$CA_TMP_DIR"

    cp -f $A14CA_PATH/* $CA_TMP_DIR
    cp -f $MODDIR/system/etc/security/cacerts/* $CA_TMP_DIR

    chown -R 0:0 "$CA_TMP_DIR"
    set_context "$A14CA_PATH" "$CA_TMP_DIR"
    CNUM="$(ls -1 $CA_TMP_DIR | wc -l)"
    if [ "$CNUM" -gt 10 ]; then
        mount -o bind "$CA_TMP_DIR" $A14CA_PATH
    fi
    umount "$TEMCA_TMP_DIRP_CA_TMP_DIRDIR"
    rmdir "$CA_TMP_DIR"
    rm -rf "$CA_TMP_DIR"
else 
    chown -R 0:0 $MODDIR/system/etc/security/cacerts
    default_selinux_context=u:object_r:system_file:s0
    selinux_context=$(ls -Zd /system/etc/security/cacerts | awk '{print $1}')
    if [ -n "$selinux_context" ] && [ "$selinux_context" != "?" ]; then
        chcon -R $selinux_context $MODDIR/system/etc/security/cacerts
    else
        chcon -R $default_selinux_context $MODDIR/system/etc/security/cacerts
    fi    
fi

    