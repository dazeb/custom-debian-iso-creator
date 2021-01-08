function deploystaticfiles() {
  set -x
  set -e

  # After in-chroot configuration is complete override any files from 'static'
  rsync -avr --exclude="*\.interpolateme*" ${HOME}/${1}/ ${HOME}/LIVE_BOOT/chroot/

  # Do variable substition for select files with '.interpolateme' in the name.
  # That token will be removed from the output file name. Use %P to print only
  # the path from the search root, not the absolute path.
  find ${HOME}/${1} -name "*\.interpolateme*" -type f -printf "%P\0" |
    while IFS= read -r -d '' file; do
      echo "${file}"
      updated=$(echo ${file} | sed "s|\.interpolateme||g")

      echo "From: ${file}"
      echo "To: ${updated}"

      user=${user} \
        release=${release} \
        server_address=${server_address} \
        proxy_address=${proxy_address} \
        envsubst \${user},\${release},\${server_address},\${proxy_address} < ${HOME}/${1}/${file} > ${HOME}/LIVE_BOOT/chroot/${updated}
    done
  set +x
}
