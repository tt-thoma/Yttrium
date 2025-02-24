# -*- encoding: utf-8 -*-
# tt_thoma

import os
from time import time
from zipfile import ZipFile, ZIP_DEFLATED

input("Press enter to start...")
print()
all_start_time = time()
versions = (path if os.path.isdir(path) else None for path in os.listdir())

for ver in versions:
    if ver is None:
        continue
    if ver.startswith("."):
        print(f"[skipped {ver}]")
        continue
    
    start_time = time()
    print(f"Compressing folder {ver}")
    zip_file = ZipFile(ver + ".zip", "w", ZIP_DEFLATED)
    
    for file in os.listdir(ver):
        path = os.path.join(ver, file)
        
        if not os.path.isfile(path):
            print(f"> [skipped {path}]")
            continue
        
        
        print("> Compressing", path)
        zip_file.write(path, file)
    
    zip_file.close()
    print(f"Done! {round(time() - start_time, 3)}s")

print(f"All done! {round(time() - all_start_time, 3)}s")
print()
input("Press enter to exit...")
