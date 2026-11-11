"""Package only submission files; exclude local caches, credentials and device tokens."""
from pathlib import Path
import hashlib
import zipfile

root = Path(__file__).resolve().parents[1]
out = root / 'submission' / 'Cloud_Courier_Activity14_Submission.zip'
out.parent.mkdir(exist_ok=True)
files = {}
for name in ['lib', 'assets', 'test', 'android']:
    for path in (root / name).rglob('*'):
        rel = path.relative_to(root)
        if not path.is_file() or any(x in {'.gradle', '.cxx', 'build', '.kotlin'} for x in rel.parts):
            continue
        if path.name in {'local.properties', 'key.properties', 'GeneratedPluginRegistrant.java'} or path.suffix in {'.jks', '.keystore', '.iml', '.log'}:
            continue
        files['Source/' + rel.as_posix()] = path
for name in ['pubspec.yaml', 'pubspec.lock', 'analysis_options.yaml', '.gitignore', '.metadata', 'README.md']:
    files['Source/' + name] = root / name
for path in (root / 'docs' / 'evidence').glob('*'):
    if path.is_file():
        files['Evidence/' + path.name] = path
for archive, source in {
    'Evidence/RESULTS.md': 'docs/TEST_RESULTS.md',
    'Evidence/PAYLOAD.json': 'docs/PAYLOAD.json',
    'Reflection.md': 'docs/REFLECTION.md',
    'SUBMISSION_NOTE.md': 'docs/SUBMISSION_NOTE.md',
    'VERIFICATION.md': 'docs/VERIFICATION.md',
}.items():
    files[archive] = root / source
manifest = ''.join(f'{hashlib.sha256(path.read_bytes()).hexdigest()}  {name}\n' for name,path in sorted(files.items()))
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as archive:
    for name,path in sorted(files.items()):
        archive.write(path, name)
    archive.writestr('SHA256SUMS.txt', manifest)
with zipfile.ZipFile(out) as archive:
    assert archive.testzip() is None
    for line in manifest.splitlines():
        digest,name = line.split('  ',1)
        assert hashlib.sha256(archive.read(name)).hexdigest() == digest
    for required in ['Source/android/gradlew', 'Source/android/gradle/wrapper/gradle-wrapper.jar', 'Source/lib/main.dart', 'Source/pubspec.lock', 'Source/assets/images/default.png', 'Source/assets/images/promo.png', 'Evidence/RESULTS.md', 'Reflection.md', 'SUBMISSION_NOTE.md']:
        assert required in archive.namelist(), required
    archive.extractall(out.parent)
    for entry in archive.infolist():
        mode = (entry.external_attr >> 16) & 0o777
        if mode:
            (out.parent / entry.filename).chmod(mode)
print(f'Verified {len(files)+1} ZIP entries, CRC and SHA-256; {out.stat().st_size} bytes')
print(out)
