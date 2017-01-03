# watch script
inotifywait -e close_write,moved_to,create -mr data/ src/ |
while read path action file; do
  echo "The file '$file' appeared in directory '$path' via '$action'"
  crystal bin/run.cr
  echo "Done"
done
