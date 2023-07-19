echo off

goto(){
  # Linux code is run on linux machines
  echo "detected: $(uname -o) detected"
}

goto $@
exit

:(){
  rem Windows script here
  echo %OS% found and Linux ignored
  exit