" --------------------------------
" Add our plugin to the path
" --------------------------------
python import sys
python import vim
python sys.path.append(vim.eval('expand("<sfile>:h")'))

" --------------------------------
"  Function(s)
" --------------------------------
function! vim_shell_executor#ExecuteWithShellProgram(selection_or_buffer)
python << endPython
from vim_shell_executor import *

def get_option_or_default(key, val):
    if int(vim.eval('exists("{}")'.format(key))):
        return vim.eval(key)
    return val

def create_new_buffer(contents):
    delete_old_output_if_exists()
    win_position = get_option_or_default('g:executor_output_win_position', 'aboveleft')
    win_height = get_option_or_default('g:executor_output_win_height', '')
    vim.command('{} {}split executor_output'.format(win_position, win_height))
    vim.command('normal! ggdG')
    vim.command('setlocal filetype=text')
    vim.command('setlocal buftype=nowrite')
    try:
        vim.command('call append(0, {0})'.format(contents))
    except:
        for index, line in enumerate(contents):
            vim.current.buffer.append(line)

def delete_old_output_if_exists():
    if int(vim.eval('buflisted("executor_output")')):
        capture_buffer_height_if_visible()
        vim.command('bdelete executor_output')

def capture_buffer_height_if_visible():
    executor_output_winnr = int(vim.eval('bufwinnr(bufname("executor_output"))'))
    if executor_output_winnr > 0:
        executor_output_winheight = vim.eval('winheight("{}")'.format(executor_output_winnr))
        vim.command("let g:executor_output_win_height = {}".format(executor_output_winheight))

def get_visual_selection():
    buf = vim.current.buffer
    starting_line_num, col1 = buf.mark('<')
    ending_line_num, col2 = buf.mark('>')
    return vim.eval('getline({}, {})'.format(starting_line_num, ending_line_num))

def get_correct_buffer(buffer_type):
    if buffer_type == "buffer":
        return vim.current.buffer
    elif buffer_type == "selection":
        return get_visual_selection()

def execute():
    first_line = vim.current.buffer[0]
    buffer_contents = get_correct_buffer(vim.eval("a:selection_or_buffer"))
    shell_program_output = get_program_output_from_buffer_contents(first_line, buffer_contents)
    create_new_buffer(shell_program_output)

execute()

endPython
endfunction
