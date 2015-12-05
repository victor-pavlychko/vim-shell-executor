import subprocess
import os

INPUT_FILE = "/tmp/input"
ERROR_LOG = "/tmp/error.log"
RESULTS_FILE = "/tmp/results"

def get_command_and_input(first_line, buffer_contents):
    if buffer_contents[0].startswith("#!"):
        return (buffer_contents[0][2:], buffer_contents[1:])
    elif first_line.startswith("#!"):
        return (first_line[2:], buffer_contents)
    else:
        return (buffer_contents[0], buffer_contents[1:])


def get_program_output_from_buffer_contents(first_line, buffer_contents):
    (command, command_input) = get_command_and_input(first_line, buffer_contents)
    write_buffer_contents_to_file(INPUT_FILE, command_input)
    execute_file_with_specified_shell_program(command)
    errors = read_file_lines(ERROR_LOG)
    std_out = read_file_lines(RESULTS_FILE)
    new_buf = errors + std_out
    return new_buf


def write_buffer_contents_to_file(file_name, contents):
    with open(file_name, "w") as f:
        for line in contents:
            f.write(line + "\n")


def execute_file_with_specified_shell_program(shell_command):
    try:
        subprocess.check_call("{0} {1} {2} > {3} 2> {4}".format(
            shell_command,
            redirect_or_arg(shell_command),
            INPUT_FILE,
            RESULTS_FILE,
            ERROR_LOG),
            shell=True
        )
    except:
        pass


def redirect_or_arg(shell_command):
    redirect_or_agr = "<"
    if shell_command == "coffee":
        redirect_or_agr = ""
    return redirect_or_agr


def read_file_lines(file_to_read):
    if os.path.isfile(file_to_read):
        with open(file_to_read, "r") as f:
            return [l.rstrip('\n') for l in f.readlines()]
