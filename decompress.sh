#!/bin/bash
SRC_DIR=$HOME/drugs_tweets
LOG_DIR=$HOME/log
ARCHIVE_DIR=$SRC_DIR/archive
LOG_FILE=$LOG_DIR/decompress_$(date +%Y%m%d_%H%M%S).log
echo "Logfile name is $LOG_FILE"
echo "$(date +%Y%m%d_%H%M%S): Starting $0" > $LOG_FILE

cd $SRC_DIR
for tar_file in ${SRC_DIR}/*.tar
do
  echo "$(date +%Y%m%d_%H%M%S): Extracting ${tar_file} from ${SRC_DIR}" >> $LOG_FILE
  tar -xf $tar_file
  if [[ $? -ne 0 ]]; then
    echo "$(date +%Y%m%d_%H%M%S): Failed to extract ${tar_file}" >> $LOG_FILE
    exit 1
  fi
  mv $tar_file $ARCHIVE_DIR
  echo "$(date +%Y%m%d_%H%M%S): Moved $tar_file to $ARCHIVE_DIR after successful processing" >> $LOG_FILE
done

echo "$(date +%Y%m%d_%H%M%S): Successfully completed extracting all tar files" >> $LOG_FILE
echo "$(date +%Y%m%d_%H%M%S): Uncompressing all bz2 files from ${SRC_DIR}" >> $LOG_FILE

find . -type f -name '*.bz2' -exec bzip2 -d {} \;
if [[ $? -ne 0 ]]; then
  echo "$(date +%Y%m%d_%H%M%S): Failed to uncompress some bz2 files" >> $LOG_FILE
  exit 1
fi
echo "$(date +%Y%m%d_%H%M%S): Successfully completed compressing bz2 files" >> $LOG_FILE

output_file=`find . -type f -name '*.json' | sed 's:./\([0-9]*\)/\([0-9]*\)/\([0-9]*\)/\([0-9]*\)/\([0-9]*\).json:\1-\2-\3.json:'| uniq`

for file in ${output_file}
do
  echo "$(date +%Y%m%d_%H%M%S): Concatenating json output files to ${SRC_DIR}/${file}" >> $LOG_FILE
  if [ ! -s $file ]
  then
    touch $file
    file_date=`basename $file '.json'`
    year=`echo $file_date|cut -d '-' -f 1`
    month=`echo $file_date|cut -d '-' -f 2`
    day=`echo $file_date|cut -d '-' -f 3`
    find ${year}/${month}/${day} -type f -name '*.json' -exec cat {} + > ${file}
    if [[ $? -ne 0 ]]; then
      echo "$(date +%Y%m%d_%H%M%S): Failed concatenating json files" >> $LOG_FILE
    else
      echo "$(date +%Y%m%d_%H%M%S): Successfully completed concatenating json files into $file" >> $LOG_FILE
      rm -rf ${year}/${month}/${day}
    fi
  else
    echo "$(date +%Y%m%d_%H%M%S): $file already exists. Please remove ${SRC_DIR}/${file} and re-execute" >>$LOG_FILE
  fi
done

