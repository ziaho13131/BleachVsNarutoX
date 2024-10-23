import sys
import subprocess

adl_exe = ''
run_dir = ''


def main():
    command = '"' + adl_exe + '"' + \
              ' -runtime "' + run_dir + '"' + \
              ' -nodebug' + \
              ' "' + run_dir + '/META-INF/AIR/application.xml"' + \
              ' "' + run_dir + '"'
    process = subprocess.Popen(
        command,
        shell=True,
        stdout=subprocess.PIPE,
        stdin=subprocess.PIPE,
        stderr=subprocess.STDOUT
    )

    stdout = process.stdout
    while process.poll() is None:
        line = stdout.readline()
        line = line.strip()
        if line is not None:
            message = line.decode('utf8', 'ignore')
            print(message)


# Program entry point
if __name__ == '__main__':
    adl_exe = sys.argv[1]
    run_dir = sys.argv[2]

    main()
