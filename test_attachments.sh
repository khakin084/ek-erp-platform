#!/usr/bin/env bash
set -e
P="tmp/_probe/$(date +%s)"
X="docker compose exec -T -u www-data -e HOME=/tmp"

echo "1. ek-core stages"
$X ek-core php artisan tinker --execute="
  Storage::disk('attachments')->put('$P/file', 'probe');
  echo 'ok';"

echo "2. ek-trades claims (move into a new nested dir)"
$X ek-trades php artisan tinker --execute="
  Storage::disk('attachments')->move('$P/file', '_probe/claimed/deep/file');
  echo 'ok';"

echo "3. ek-core reads it back (download path)"
$X ek-core php artisan tinker --execute="
  echo Storage::disk('attachments')->get('_probe/claimed/deep/file');"

echo "4. ownership on disk"
docker compose exec -T ek-core ls -lnR /var/ek-attachments/_probe /var/ek-attachments/tmp/_probe

echo "5. ek-core cleanup can delete ek-trades's dirs"
$X ek-core php artisan tinker --execute="
  Storage::disk('attachments')->deleteDirectory('_probe');
  Storage::disk('attachments')->deleteDirectory('tmp/_probe');
  echo 'ok';"