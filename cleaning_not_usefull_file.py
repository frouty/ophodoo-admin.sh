# -*- coding: utf-8 -*-
##############################################################################
# Script to clean a directory
# where all the odt attachment are saved with ODDO client.
# to clean all files that are not usefull.
# delete files older than tree months : (3*30)*24*60*60
# how to use it
# cd oph_admin.sh
# ./cleaning.py ne marche pas
# python cleaning.py
# comme cela ça ne marche pas mais ca marche dans eclipse: run / run as / python run...
# arg = relative path to dir to delete eg : python cleaning.py MAI19 (not /home/lfs/MAI19

# le mettre dans un cron job
# contab -e dans un user standard
# 
##############################################################################

import os, glob, logging, sys

logging.basicConfig(level = logging.INFO)
logger = logging.getLogger(__name__)

if len(sys.argv) != 2:
    print( "usage", sys.argv[0], "<dir>")
    sys.exit(1)

# tree month ago
#now = time.time()
#TREEMONTHAGO = now -90*24*60*60

# those patterns should match the name in ODOO report
patterns = ['Prescription_*',
            'BDS[ ]Remise[ ]Chq*',
            'Appointment[ ]Memo*',
            #'Biology[ ]Prescription[ ]Report*',
            'Certificat*',
            #'Cardio[ ]Reporting*',
            # 'Diabetic[ ]Reporting*',
            'Etat[ ]LM*',
            'Etat[ ]NORD*',
            'Etat[ ]SUD*',
            'FDS[ ]CAFAT[ ]MUT*',
            'FDS[ ]TIERS[ ]PAYANT*',
            'Fiche[ ]Liaison*'
            #'Medication[ ]Report*',
            #'Medication*.odt',
            'Memo*',
            #'Multifocal[ ]and[ ]Sunglasses*',
            #'Multifocal[ ]and[ ]Reading*',
            # 'OCT[ ]Report*',
            #'Single[ ]Vision*',
            #'Fiche[ ]Liaison*',
            'Memo[ ]de[ ]rendez[ ]vous*',
            'Ordonnance[ ]IVT*',
            'Operating[ ]Room[ ]Report*',
            'Prescription[ ]OR*',
            'BDX[ ]Remise[ ]Chq*',
            #'Medication[ ]Report*',
            # 'Plain[ ]Report[ ]Small[ ]Font*',
            #'PKE[ ]ICP[ ]Report*',
            #'Precription[ ]OR*',
            #'Near[ ]Vision[ ]Glasses*',
            'Planning[ ]Notification*',
            #'PresOR_*',
            #'Reading[ ]Glasses*',
            #'Radiology*',
            #'Reading*',
            #'Single*',
            'Check[ ]List[ ]Block[ ]Agenda*',
            'Bloc[ ]Agenda[ ]Report*',
            'Hospit[ ]Reporting*',
            'Request[ ]Bizone*',
            # 'Fluoresceine[ ]Angiography[ ]Report',
            'Memo[ ]Report*',
              ]

WORKING_DIR = os.path.expanduser('~') + "/" + sys.argv[1]

logger.info('working dir is: %s', WORKING_DIR)

#for pattern in patterns:
#    logger.info('pattern is: %s', pattern)
#    FILE_PATTERN = WORKING_DIR + '/' + pattern
#    logger.info('File path pattern is: %s', FILE_PATTERN)
#    
#    for pathfile in glob.glob(FILE_PATTERN):
#        logger.info('pathfile: %s', pathfile)
#        if os.stat(pathfile).st_ctime > TREEMONTHAGO:
#        logger.info("pathfile to be removed : %s", pathfile)
#        os.remove(pathfile)

for pattern in patterns:
    logger.info('pattern is: %s', pattern)
    FILE_PATTERN = WORKING_DIR + '/' + pattern
    logger.info('FILE_PATTERN is:%s', FILE_PATTERN)
    logger.info('glob.glob(FILE_PATTERN)is: %s', glob.glob(FILE_PATTERN))
    [os.remove(x) for x in glob.glob(FILE_PATTERN)]
