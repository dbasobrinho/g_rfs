find -mtime -1 -mtime -10 -type f -exec ls -ltra {} \;


######-mtime -0.5
######-1 the last 24 hours
######-0.5 the last 12 hours
######-0.25 the last 6 hours
######+3 more than three days