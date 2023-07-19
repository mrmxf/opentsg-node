# usage> msgtsg installer
# short> install msgtsg from mrmxf.com
# long>  install msgtsg from mrmxf.com
#                       _
#   _ __    ___  __ _  | |_   ___  __ _
#  | '  \  (_-< / _` | |  _| (_-< / _` |
#  |_|_|_| /__/ \__, |  \__| /__/ \__, |
#               |___/             |___/
#
# usage from cli:
#
#      curl https://mrmxf.com/get/msgtsg | bash

EXE="msgtsg-node"
URL=https://mrmxf.com/get
V=_lx

if [[ "aarch64" == $(uname -m) ]]; then
  # ARM architecture
  V=_la
fi

# ------------------------------------------------------------------------------
DST=/usr/local/bin/$EXE

echo "1. Fetching executable"
sudo curl --no-progress-meter $URL/$V$EXE -o /usr/local/bin/$EXE -o $DST
sudo chmod +x $DST

# ------------------------------------------------------------------------------
DST=/usr/local/lib/$EXE/
echo "2. Fetching libraries"
curl --no-progress-meter $URL/$V$EXE-so.zip -o /tmp/$EXE-so.zip
sudo mkdir -p $DST

# ------------------------------------------------------------------------------
echo "3. Installing 7th sense libraries"
sudo unzip -oq /tmp/$V$EXE-so.zip -d $DST
sudo chmod +x $DST
export LD_LIBRARY_PATH=$DST:$LD_LIBRARY_PATH

# ------------------------------------------------------------------------------
echo "4. $EXE can be upgraded by typing:  curl https://mrmxf.com/get/$EXE | bash"
