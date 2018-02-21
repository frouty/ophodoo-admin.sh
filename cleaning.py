# -*- coding: utf-8 -*-
##############################################################################
# Script to clean a directory
# where all the odt attachment are saved with ODDO client.
# how to use it
# cd oph_admin.sh
# ./cleaning.py
# comme cela ça ne marche pas mais ca marche dans eclipse: run as...


#
##############################################################################

import os, glob, logging

logging.basicConfig(level = logging.INFO)
logger = logging.getLogger(__name__)

# those patterns should match the name in ODOO report
patterns = ['BDS[ ]Remise[ ]Chq*',
          'Appointment[ ]Memo*',
          'Biology[ ]Prescription[ ]Report*',
          'Cardio[ ]Reporting*',
          'Diabetic[ ]Reporting*',
          'Etat[ ]LM*',
          'Etat[ ]NORD*',
          'Etat[ ]SUD*',
          'FDS[ ]CAFAT[ ]MUT*',
          'FDS[ ]TIERS[ ]PAYANT*',
          'Fiche[ ]Liaison*'
          'Medication[ ]Report*',
          'Multifocal[ ]and[ ]Sunglasses*',
          'Multifocal[ ]and[ ]Reading*',
          'OCT[ ]Report*',
          'Single[ ]Vision*',
          'Fiche[ ]Liaison*',
          'Memo[ ]de[ ]rendez[ ]vous*',
          'Ordonnance[ ]IVT*',
          'Operating[ ]Room[ ]Report*',
          'Prescription[ ]OR*',
          'BDX[ ]Remise[ ]Chq*',
          'Medication[ ]Report*',
          'Plain[ ]Report[ ]Small[ ]Font*',
          'PKE[ ]ICP[ ]Report*',
          'Precription[ ]OR*',
          'Near[ ]Vision[ ]Glasses*',
          'Planning[ ]Notification*',
          'Reading[ ]Glasses*',
          'Check[ ]List[ ]Block[ ]Agenda*',
          'Bloc[ ]Agenda[ ]Report*',
          'Hospit[ ]Reporting*',
          'Request[ ]Bizone*',
          'Fluoresceine[ ]Angiography[ ]Report',
          ]


WORKING_DIR = os.path.expanduser('~') + '/FEV17'

logger.info('le working dir is: %s', WORKING_DIR)

for pattern in patterns:
    logger.info('pattern is: %s', pattern)
    FILE_PATTERN = WORKING_DIR + '/' + pattern
    logger.info('File pattern is: %s', FILE_PATTERN)
    for file in glob.glob(FILE_PATTERN):
        logger.info('file to be deleted is : %s', file)
    [os.remove(x) for x in glob.glob(FILE_PATTERN)]