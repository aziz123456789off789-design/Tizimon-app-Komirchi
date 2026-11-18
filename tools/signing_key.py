"""Generate a private app-specific release key once. Never print passwords."""
from pathlib import Path
import secrets
import subprocess

root = Path(__file__).resolve().parents[1]
key = root / '.tools' / 'keys' / 'dokon-release.jks'
properties = root / 'android' / 'key.properties'
if key.exists() and properties.exists():
    print('Existing release key preserved.')
elif key.exists() or properties.exists():
    raise RuntimeError('Incomplete signing configuration; existing files preserved.')
else:
    key.parent.mkdir(parents=True, exist_ok=True)
    password = secrets.token_urlsafe(32)
    keytool = next((root / '.tools' / 'java').glob('*/bin/keytool.exe'))
    subprocess.run([str(keytool), '-genkeypair', '-keystore', str(key),
                    '-storepass', password, '-keypass', password,
                    '-alias', 'dokon', '-keyalg', 'RSA', '-keysize', '3072',
                    '-validity', '10000', '-dname', 'CN=Dokon, OU=Mobile, O=Dokon, C=UZ'],
                   check=True, capture_output=True)
    properties.write_text(f'storeFile={key.as_posix()}\nstorePassword={password}\nkeyPassword={password}\nkeyAlias=dokon\n', encoding='utf-8')
    print('Private release key created. Keep .tools/keys and android/key.properties for future updates.')
