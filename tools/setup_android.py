"""Install portable Android build tools inside this project's ignored .tools."""
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
import hashlib
import urllib.request
import zipfile

ROOT = Path(__file__).resolve().parents[1] / '.tools'
ROOT.mkdir(exist_ok=True)

def download(url, target, checksum=None):
    if not target.exists():
        print(f'Downloading {target.name}', flush=True)
        with urllib.request.urlopen(url, timeout=120) as source, target.open('wb') as dest:
            while chunk := source.read(1024 * 1024):
                dest.write(chunk)
    if checksum:
        actual = hashlib.sha256(target.read_bytes()).hexdigest()
        if actual != checksum:
            raise RuntimeError(f'Checksum mismatch: {target}')
    return target

def java():
    url = 'https://aka.ms/download-jdk/microsoft-jdk-21-windows-x64.zip'
    archive = download(url, ROOT / 'jdk.zip')
    directory = ROOT / 'java'
    if not directory.exists():
        with zipfile.ZipFile(archive) as z:
            z.extractall(directory)
    print('Java ready: ' + str(next(directory.glob('*/bin/java.exe')).parent.parent), flush=True)

def android():
    archive = download('https://dl.google.com/android/repository/commandlinetools-win-15859902_latest.zip', ROOT / 'android-cli.zip')
    target = ROOT / 'android-sdk' / 'cmdline-tools' / 'latest'
    if not (target / 'bin' / 'sdkmanager.bat').exists():
        with zipfile.ZipFile(archive) as z:
            for entry in z.infolist():
                relative = Path(entry.filename).relative_to('cmdline-tools')
                output = target / relative
                if not output.resolve().is_relative_to(target.resolve()):
                    raise RuntimeError('Unsafe archive path')
                if entry.is_dir():
                    output.mkdir(parents=True, exist_ok=True)
                else:
                    output.parent.mkdir(parents=True, exist_ok=True)
                    output.write_bytes(z.read(entry))
    print('Android command-line tools ready.', flush=True)

with ThreadPoolExecutor(max_workers=2) as pool:
    jobs = [pool.submit(java), pool.submit(android)]
    for job in jobs:
        job.result()
