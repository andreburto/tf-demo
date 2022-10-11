import os

from datetime import datetime


DATE_REPLACE_STR = "{{date}}"
STATIC_DIR = "static"


def main():
    base_path = os.path.abspath(os.path.dirname(__file__))
    index_template_full_path = f"{base_path}/{STATIC_DIR}/index.template"
    index_webpage_full_path = f"{base_path}/{STATIC_DIR}/index.html"

    with open(index_template_full_path, "rb") as fhi:
        with open(index_webpage_full_path, "wb") as fho:
            for line in fhi.readlines():
                read_line = line.decode().replace("\n", "")
                if DATE_REPLACE_STR in read_line:
                    new_line = read_line.replace(
                        DATE_REPLACE_STR, datetime.now().strftime("%Y-%m-%d @ %H:%M:%S"))
                    fho.write(f"{new_line}\n".encode())
                else:
                    fho.write(f"{read_line}\n".encode())


if __name__ == "__main__":
    main()
