import datetime
import json
import os
import shutil
import subprocess
import sys
import time
import zipfile


def copytree(source, destination, ignore=None):
    """implementation of shutil.copytree
    original sometimes throw error on folders create"""
    for item in os.listdir(source):
        # skip git files
        if '.gitkeep' in item:
            continue
        sourcePath = os.path.join(source, item)
        destinationPath = os.path.join(destination, item)
        # use copytree for directory
        if not os.path.isfile(sourcePath):
            copytree(sourcePath, destinationPath, ignore)
            continue
        # make dir by os module
        dirName, fileName = os.path.split(destinationPath)
        if not os.path.isdir(dirName):
            os.makedirs(dirName)
        # skip files by ignore pattern
        if ignore:
            ignored_names = ignore(source, os.listdir(source))
            if fileName in ignored_names:
                continue
        # copy file
        shutil.copy2(sourcePath, destinationPath)


def zipFolder(source, destination, mode='w', compression=zipfile.ZIP_STORED):
    """ ZipFile by default dont create folders info in result zip """

    def dirInfo(path):
        """return fixed ZipInfo for directory"""
        info = zipfile.ZipInfo(path, now)
        info.filename = info.filename[seek_offset:]
        if not info.filename:
            return None
        if not info.filename.endswith('/'):
            info.filename += '/'
        info.compress_type = compression
        return info

    def fileInfo(path):
        """return fixed ZipInfo for file"""
        info = zipfile.ZipInfo(path, now)
        info.external_attr = 33206 << 16  # -rw-rw-rw-
        info.filename = info.filename[seek_offset:]
        info.compress_type = compression
        return info

    with zipfile.ZipFile(destination, mode, compression) as zipfh:
        now = tuple(datetime.datetime.now().timetuple())[:6]
        seek_offset = len(source) + 1
        for dirName, _, files in os.walk(source):
            info = dirInfo(dirName)
            if info:
                zipfh.writestr(info, '')
            for fileName in files:
                filePath = os.path.join(dirName, fileName)
                info = fileInfo(filePath)
                zipfh.writestr(info, open(filePath, 'rb').read())


def processRunning(path):
    """Cheek is process runing, no"""
    processName = os.path.basename(path).lower()
    try:
        import psutil
        for proc in psutil.process_iter():
            if proc.name().lower() == processName:
                return True
        return False
    except ImportError:
        if os.name == 'nt':
            for task in (x.split() for x in subprocess.check_output('tasklist').splitlines()):
                if task and task[0].lower() == processName:
                    return True
            return False
        else:
            print('cant list process on your system')
            print('run -> pip install psutil')
            raise NotImplementedError


def buildFlash():
    if not BUILD_FLASH:
        return

    # working directory URI for Animate
    flashWD = os.getcwd().replace('\\', '/').replace(':', '|')

    # JSFL file with commands for Animate
    jsflFile = 'build.jsfl'
    jsflContent = ''

    files = set()

    # add publishDocument command for all *.fla and *.xfl files
    for dirPath, _, fileNames in os.walk('as3'):
        for fileName in fileNames:
            if fileName.endswith('.fla') or fileName.endswith('.xfl'):
                dirPath = dirPath.replace('\\', '/')
                logName = fileName.replace('.fla', '.log').replace('.xfl', '.log')
                files.add((dirPath, fileName, logName))

    if not files:
        return

    for dirPath, fileName, logName in files:
        documentURI = 'file:///{}/{}/{}'.format(flashWD, dirPath, fileName)
        logFileURI = 'file:///{}/{}'.format(flashWD, logName)
        jsflContent += 'fl.publishDocument("{}", "Default");\n'.format(documentURI)
        jsflContent += 'fl.compilerErrors.save("{}", false, true);\n'.format(logFileURI)
        jsflContent += '\n'

    # add close command only if Animate not opened
    if not processRunning(CONFIG.software.animate):
        jsflContent += 'fl.quit(false);'

    # save commands for Animate
    with open(jsflFile, 'w') as fh:
        fh.write(jsflContent)

    # run Animate
    try:
        subprocess.call([CONFIG.software.animate, '-e', jsflFile, '-AlwaysRunJSFL'], stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as e:
        print (e)

    # publishing can be asynchronous when Animate is already opened
    # so waiting script file unlock to remove, which means publishing is done
    while os.path.exists(jsflFile):
        try:
            os.remove(jsflFile)
        except:  # NOSONAR
            time.sleep(.1)

    for dirPath, fileName, logName in files:
        log_data = ''
        if os.path.isfile(logName):
            data = open(logName, 'r').read().splitlines()
            if len(data) > 1:
                log_data = '\n'.join(data[:-2])
            os.remove(logName)

        if log_data:
            print ('Failed publish: {}/{}'.format(dirPath, fileName))
            print (log_data)
        else:
            print ('Published: {}/{}'.format(dirPath, fileName))


def buildPython():
    for dirPath, _, fileNames in os.walk('res/scripts'):
        for fileName in fileNames:
            if not fileName.endswith('.py'):
                continue
            filePath = "{}/{}".format(dirPath, fileName).replace('\\', '/')
            try:
                subprocess.check_output([CONFIG['software']['python'], '-m', 'py_compile', filePath],
                                        stderr=subprocess.STDOUT).decode()
                print ('Compiled: {}'.format(filePath))
            except subprocess.CalledProcessError as e:
                print ('\nFailed compile: {}'.format(filePath))
                output = e.output.decode()
                print (output)


# handle args from command line
BUILD_FLASH = 'flash' in sys.argv
COPY_INTO_GAME = 'ingame' in sys.argv
CREATE_DISTRIBUTE = 'distribute' in sys.argv

# load config
assert os.path.isfile('build.json'), 'Config not found'
with open('build.json', 'r') as fh:
    CONFIG = json.loads(fh.read())

GAME_FOLDER = CONFIG['game']['folder']
GAME_VERSION = CONFIG['game']['version']

# cheek in-game folder
WOT_PACKAGES_DIR = '{wot}/mods/{version}/'.format(wot=GAME_FOLDER, version=GAME_VERSION)
if COPY_INTO_GAME:
    assert os.path.isdir(WOT_PACKAGES_DIR), 'WoT mods folder not found'

# package data
PACKAGE_NAME = '{author}.{name}_{version}.wotmod'.format(author=CONFIG['info']['author'],
                                                         name=CONFIG['info']['id'], version=CONFIG['info']['version'])

# generate package meta file
META = """<root>
	<!-- Technical MOD ID -->
	<id>{author}.{id}</id>
	<!-- Package version -->
	<version>{version}</version>
	<!-- Human readable name -->
	<name>{name}</name>
	<!-- Human readable description -->
	<description>{description}</description>
</root>""".format(author=CONFIG['info']['author'], id=CONFIG['info']['id'], name=CONFIG['info']['name'],
                  description=CONFIG['info']['description'], version=CONFIG['info']['version'])

# prepere folders
if os.path.isdir('temp'):
    shutil.rmtree('temp')
os.makedirs('temp')
if os.path.isdir('build'):
    shutil.rmtree('build')
os.makedirs('build')

# build flash
buildFlash()

# build python
buildPython()

# copy all staff
if os.path.isdir('resources/in'):
    copytree('resources/in', 'temp/res')
if os.path.isfile('LICENSE'):
    shutil.copy2('LICENSE', 'temp')
if os.path.isfile('README.md'):
    shutil.copy2('README.md', 'temp')
if os.path.isfile('res/gui/flash/GUIFlash.swf'):
    os.makedirs('temp/res/gui/flash')
    shutil.copy2('res/gui/flash/GUIFlash.swf', 'temp/res/gui/flash')
copytree('res/scripts', 'temp/res/scripts', ignore=shutil.ignore_patterns('*.py'))
with open('temp/meta.xml', 'w') as fh:
    fh.write(META)

# create package
zipFolder('temp', 'build/{}'.format(PACKAGE_NAME))

# copy package into game
if COPY_INTO_GAME:
    shutil.copy2('build/{}'.format(PACKAGE_NAME), WOT_PACKAGES_DIR)

# create distribution
if CREATE_DISTRIBUTE:
    os.makedirs('temp/distribute/mods/{}'.format(GAME_VERSION))
    shutil.copy2('build/{}'.format(PACKAGE_NAME), 'temp/distribute/mods/{}'.format(GAME_VERSION))
    if os.path.isdir('resources/out'):
        copytree('resources/out', 'temp/distribute')
    zipFolder('temp/distribute', 'build/{name}_{version}_{wotversion}.zip'.format(name=CONFIG['info']['id'], version=CONFIG['info']['version'], wotversion=GAME_VERSION), compression=zipfile.ZIP_DEFLATED)
# list for cleaning
cleanup_list = set([])

# builder temporary
cleanup_list.add('temp')

# Animate unnecessary
cleanup_list.add('EvalScript error.tmp')
cleanup_list.add('as3/DataStore')

# python bytecode
for dirName, _, files in os.walk('res'):
    for fileName in files:
        if fileName.endswith('.pyc'):
            cleanup_list.add(os.path.join(dirName, fileName))

# delete files
for path in cleanup_list:
    if os.path.isdir(path):
        shutil.rmtree(path)
    elif os.path.isfile(path):
        os.remove(path)
