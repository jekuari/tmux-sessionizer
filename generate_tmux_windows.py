import sys
import os


def main():

    PARENT_DIRECTORY_PATH = sys.argv[1]
    TYPE = sys.argv[2]

    # get all the subdirectories
    subdirectories = [f for f in os.listdir(PARENT_DIRECTORY_PATH) if os.path.isdir(
        os.path.join(PARENT_DIRECTORY_PATH, f))]

    # get the parent directory name
    PARENT_DIRECTORY_NAME = os.path.basename(PARENT_DIRECTORY_PATH)

    tmux_window_args = f'tmux new-session -{"d" if TYPE == "d" else ""}s {PARENT_DIRECTORY_NAME} -c {PARENT_DIRECTORY_PATH} '

    # filter out subdirectories that don't have a .git folder
    subdirectories = [subdirectory for subdirectory in subdirectories if os.path.exists(
        f'{PARENT_DIRECTORY_PATH}/{subdirectory}/.git')]

    # generate the -n arguments for all the valid subdirectories
    for subdirectory in subdirectories:
        subdirectory_name = os.path.basename(subdirectory)
        tmux_window_args += f'-n {subdirectory_name} '

    # append the commands to open the windows
    for subdirectory in subdirectories:
        tmux_window_args += f'\\; new-window -t {PARENT_DIRECTORY_NAME} -c {PARENT_DIRECTORY_PATH}/{subdirectory} -n {subdirectory} '

    print(tmux_window_args)
    return tmux_window_args


main()
