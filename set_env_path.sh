#!/bin/bash


export MVCAM_COMMON_RUNENV=/opt/MVS/lib 

FIND_PATH=${MVCAM_COMMON_RUNENV//\//\\\/}

LD_LIBRARY_PATH=${LD_LIBRARY_PATH//${FIND_PATH}\/64:/}
LD_LIBRARY_PATH=${LD_LIBRARY_PATH//${FIND_PATH}\/32:/}
LD_LIBRARY_PATH=${LD_LIBRARY_PATH//${FIND_PATH}\/armhf:/}
LD_LIBRARY_PATH=${LD_LIBRARY_PATH//${FIND_PATH}\/aarch64:/}


LD_LIBRARY_PATH=${LD_LIBRARY_PATH//${FIND_PATH}\/64/}
LD_LIBRARY_PATH=${LD_LIBRARY_PATH//${FIND_PATH}\/32/}
LD_LIBRARY_PATH=${LD_LIBRARY_PATH//${FIND_PATH}\/armhf/}
LD_LIBRARY_PATH=${LD_LIBRARY_PATH//${FIND_PATH}\/aarch64/}

ADD_TO_LIBRARY_PATH=

# put dynamic library path to LD_LIBRARY_PATH
if [ -d "/opt/MVS/lib/32" ]; then	
	if ! echo ${ADD_TO_LIBRARY_PATH} | grep -q ${MVCAM_COMMON_RUNENV}/32; then
	  if [ "$ADD_TO_LIBRARY_PATH" = "" ]; then
		ADD_TO_LIBRARY_PATH=${MVCAM_COMMON_RUNENV}/32
	  else
		ADD_TO_LIBRARY_PATH=${MVCAM_COMMON_RUNENV}/32:${ADD_TO_LIBRARY_PATH}
	  fi
	fi
	
	if ! echo ${LD_LIBRARY_PATH} | grep -q ${MVCAM_COMMON_RUNENV}/32; then
	  if [ "$LD_LIBRARY_PATH" = "" ]; then
		LD_LIBRARY_PATH=${MVCAM_COMMON_RUNENV}/32
	  else
		LD_LIBRARY_PATH=${MVCAM_COMMON_RUNENV}/32:${LD_LIBRARY_PATH}
	  fi
	fi
fi

if [ -d "/opt/MVS/lib/64" ]; then
	if ! echo ${ADD_TO_LIBRARY_PATH} | grep -q ${MVCAM_COMMON_RUNENV}/64; then
	  if [ "$ADD_TO_LIBRARY_PATH" = "" ]; then
		ADD_TO_LIBRARY_PATH=${MVCAM_COMMON_RUNENV}/64
	  else
		ADD_TO_LIBRARY_PATH=${MVCAM_COMMON_RUNENV}/64:${ADD_TO_LIBRARY_PATH}
	  fi
	fi
	
	if ! echo ${LD_LIBRARY_PATH} | grep -q ${MVCAM_COMMON_RUNENV}/64; then
	  if [ "$LD_LIBRARY_PATH" = "" ]; then
		LD_LIBRARY_PATH=${MVCAM_COMMON_RUNENV}/64
	  else
		LD_LIBRARY_PATH=${MVCAM_COMMON_RUNENV}/64:${LD_LIBRARY_PATH}
	  fi
	fi
fi

if [ -d "/opt/MVS/lib/armhf" ]; then
	if ! echo ${ADD_TO_LIBRARY_PATH} | grep -q ${MVCAM_COMMON_RUNENV}/armhf; then
	  if [ "$ADD_TO_LIBRARY_PATH" = "" ]; then
		ADD_TO_LIBRARY_PATH=${MVCAM_COMMON_RUNENV}/armhf
	  else
		ADD_TO_LIBRARY_PATH=${MVCAM_COMMON_RUNENV}/armhf:${ADD_TO_LIBRARY_PATH}
	  fi
	fi
	
	if ! echo ${LD_LIBRARY_PATH} | grep -q ${MVCAM_COMMON_RUNENV}/armhf; then
	  if [ "$LD_LIBRARY_PATH" = "" ]; then
		LD_LIBRARY_PATH=${MVCAM_COMMON_RUNENV}/armhf
	  else
		LD_LIBRARY_PATH=${MVCAM_COMMON_RUNENV}/armhf:${LD_LIBRARY_PATH}
	  fi
	fi
fi

if [ -d "/opt/MVS/lib/aarch64" ]; then
	if ! echo ${ADD_TO_LIBRARY_PATH} | grep -q ${MVCAM_COMMON_RUNENV}/aarch64; then
	  if [ "$ADD_TO_LIBRARY_PATH" = "" ]; then
		ADD_TO_LIBRARY_PATH=${MVCAM_COMMON_RUNENV}/aarch64
	  else
		ADD_TO_LIBRARY_PATH=${MVCAM_COMMON_RUNENV}/aarch64:${ADD_TO_LIBRARY_PATH}
	  fi
	fi
	
	if ! echo ${LD_LIBRARY_PATH} | grep -q ${MVCAM_COMMON_RUNENV}/aarch64; then
	  if [ "$LD_LIBRARY_PATH" = "" ]; then
		LD_LIBRARY_PATH=${MVCAM_COMMON_RUNENV}/aarch64
	  else
		LD_LIBRARY_PATH=${MVCAM_COMMON_RUNENV}/aarch64:${LD_LIBRARY_PATH}
	  fi
	fi
fi

export LD_LIBRARY_PATH

#echo $LD_LIBRARY_PATH

# for common user
for i in /home/*/.profile; 
	do echo $i; 
	
	if [ ! -f "$i" ]; then
		break
	fi
	
	if [ ! -w "$i" ]; then
		echo "Permission Denied to write $i"
		continue
	fi
	
	sed -i '/^export.MVCAM_COMMON_RUNENV/d' $i
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/64://" $i
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/32://" $i
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/armhf://" $i
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/aarch64://" $i
	
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/64//" $i
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/32//" $i
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/armhf//" $i
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/aarch64//" $i
	
	sed -i '/^export.LD_LIBRARY_PATH=$/d' $i
	sed -i '/^export.LD_LIBRARY_PATH=\$LD_LIBRARY_PATH$/d' $i
	
	if grep --silent ^export.MVCAM_COMMON_RUNENV $i; then
		echo "$i: env path has already been set"    
	else
		echo "" >> $i
		echo "export MVCAM_COMMON_RUNENV=/opt/MVS/lib" >> $i
	fi
	
	if grep --silent ^export.LD_LIBRARY_PATH $i; then
		echo "" >> $i
		echo "export LD_LIBRARY_PATH=$ADD_TO_LIBRARY_PATH:\$LD_LIBRARY_PATH" >> $i
	else
		echo "" >> $i
		echo "export LD_LIBRARY_PATH=$ADD_TO_LIBRARY_PATH" >> $i
	fi
	
	source $i
done

# for common user
for i in /home/*/.bashrc; 
	do echo $i; 
	
	if [ ! -f "$i" ]; then
		break
	fi
	
	if [ ! -w "$i" ]; then
		echo "Permission Denied to write $i"
		continue
	fi
	
	sed -i '/^export.MVCAM_COMMON_RUNENV/d' $i
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/64://" $i
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/32://" $i
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/armhf://" $i
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/aarch64://" $i
	
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/64//" $i
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/32//" $i
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/armhf//" $i
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/aarch64//" $i
	
	sed -i '/^export.LD_LIBRARY_PATH=$/d' $i
	sed -i '/^export.LD_LIBRARY_PATH=\$LD_LIBRARY_PATH$/d' $i
	
	if grep --silent ^export.MVCAM_COMMON_RUNENV $i; then
		echo "$i: env path has already been set"    
	else
		echo "" >> $i
		echo "export MVCAM_COMMON_RUNENV=/opt/MVS/lib" >> $i
	fi
	
	if grep --silent ^export.LD_LIBRARY_PATH $i; then
		echo "" >> $i
		echo "export LD_LIBRARY_PATH=$ADD_TO_LIBRARY_PATH:\$LD_LIBRARY_PATH" >> $i
	else
		echo "" >> $i
		echo "export LD_LIBRARY_PATH=$ADD_TO_LIBRARY_PATH" >> $i
	fi
	
	source $i
done

# for common user
for i in /home/*/.bash_profile; 
	do echo $i; 
	
	if [ ! -f "$i" ]; then
		break
	fi
	
	if [ ! -w "$i" ]; then
		echo "Permission Denied to write $i"
		continue
	fi
	
	sed -i '/^export.MVCAM_COMMON_RUNENV/d' $i
	
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/64://" $i
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/32://" $i
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/armhf://" $i
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/aarch64://" $i
	
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/64//" $i
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/32//" $i
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/armhf//" $i
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/aarch64//" $i
	
	sed -i '/^export.LD_LIBRARY_PATH=$/d' $i
	sed -i '/^export.LD_LIBRARY_PATH=\$LD_LIBRARY_PATH$/d' $i
	
	
	if grep --silent ^export.MVCAM_COMMON_RUNENV $i; then
		echo "$i: env path has already been set"    
	else
		echo "" >> $i
		echo "export MVCAM_COMMON_RUNENV=/opt/MVS/lib" >> $i
	fi
	
	if grep --silent ^export.LD_LIBRARY_PATH $i; then
		echo "" >> $i
		echo "export LD_LIBRARY_PATH=$ADD_TO_LIBRARY_PATH:\$LD_LIBRARY_PATH" >> $i
	else
		echo "" >> $i
		echo "export LD_LIBRARY_PATH=$ADD_TO_LIBRARY_PATH" >> $i
	fi
	
	source $i
done

if [ -w /etc/profile ]; then
	# for sudo user
	sed -i '/^export.MVCAM_COMMON_RUNENV/d' /etc/profile

	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/64://" /etc/profile
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/32://" /etc/profile
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/armhf://" /etc/profile
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/aarch64://" /etc/profile

	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/64//" /etc/profile
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/32//" /etc/profile
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/armhf//" /etc/profile
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/aarch64//" /etc/profile

	sed -i '/^export.LD_LIBRARY_PATH=$/d' /etc/profile
	sed -i '/^export.LD_LIBRARY_PATH=\$LD_LIBRARY_PATH$/d' /etc/profile

	if grep --silent ^export.MVCAM_COMMON_RUNENV /etc/profile; then
		echo "/etc/profile: env path has already been set"    
	else
		echo "" >> /etc/profile
		echo "export MVCAM_COMMON_RUNENV=/opt/MVS/lib" >> /etc/profile
	fi

	if grep --silent ^export.LD_LIBRARY_PATH /etc/profile; then
		echo "export LD_LIBRARY_PATH=$ADD_TO_LIBRARY_PATH:\$LD_LIBRARY_PATH" >> /etc/profile  
	else
		echo "" >> /etc/profile
		echo "export LD_LIBRARY_PATH=$ADD_TO_LIBRARY_PATH" >> /etc/profile
	fi
	
	source /etc/profile

fi

if [ -w ~/.bashrc ]; then

	sed -i '/^export.MVCAM_COMMON_RUNENV/d' ~/.bashrc


	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/64://" ~/.bashrc
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/32://" ~/.bashrc
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/armhf://" ~/.bashrc
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/aarch64://" ~/.bashrc

	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/64//" ~/.bashrc
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/32//" ~/.bashrc
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/armhf//" ~/.bashrc
	sed -i "/^export.LD_LIBRARY_PATH*/s/${FIND_PATH}\/aarch64//" ~/.bashrc

	sed -i '/^export.LD_LIBRARY_PATH=$/d' ~/.bashrc
	sed -i '/^export.LD_LIBRARY_PATH=\$LD_LIBRARY_PATH$/d' ~/.bashrc



	if grep --silent ^export.MVCAM_COMMON_RUNENV ~/.bashrc; then
		echo "~/.bashrc: env path has already been set"    
	else
		echo "" >> ~/.bashrc
		echo "export MVCAM_COMMON_RUNENV=/opt/MVS/lib" >> ~/.bashrc
	fi

	if grep --silent ^export.LD_LIBRARY_PATH ~/.bashrc; then
		echo "export LD_LIBRARY_PATH=$ADD_TO_LIBRARY_PATH:\$LD_LIBRARY_PATH" >> ~/.bashrc
	else
		echo "" >> ~/.bashrc
		echo "export LD_LIBRARY_PATH=$ADD_TO_LIBRARY_PATH" >> ~/.bashrc
	fi


	source ~/.bashrc
fi


