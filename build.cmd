export PATH="$PATH:/c/tools/packer" 
time packer build -only virtualbox-iso windows_2012_r2.json

vagrant box add  windows_2012_r2_virtualbox.box --name windows_2012_r2