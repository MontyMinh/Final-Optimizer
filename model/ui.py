from tkinter import *
from tkinter.ttk import *
from tkinter.filedialog import askopenfile

from model import *
from model.program import *

import time


class ProgramError(Exception):
    """Class for Program Error"""
    def __init__(self):
        super().__init__(
            "An error has occured while optimizing the program\n              See the error message above and below for more details"
        )


class UI:
    def exit_message():
        print('Process Terminated')

    @classmethod
    def open_file(cls):
        """Function to collect the file path"""

        filepath = askopenfile(mode='r',
                               filetypes=[('Excel Files', '.xlsx .xlsm')])

        # If doesn't exist, display retry message
        if filepath is None:

            try:  # Change text if exist
                cls.msg['text'] = 'No File Uploaded, Retry!'
                cls.msg['foreground'] = 'red'
            except:  # New label if not exist
                cls.msg = Label(cls.root,
                                text='No File Uploaded, Retry!',
                                foreground='red')
                cls.msg.grid(row=4, columnspan=3, pady=10)

            Data.filepath = ""

        # If it does, display success message
        else:
            last_str_index = filepath.name[::-1].index('/')
            cls.filepath = filepath.name
            try:
                cls.msg[
                    'text'] = f'{cls.filepath[-last_str_index:]} \nUploaded Successfully!'
                cls.msg['foreground'] = 'green'
            except:
                # Format filepath
                cls.msg = Label(
                    cls.root,
                    text=
                    f'{cls.filepath[-last_str_index:]} \nUploaded Successfully!',
                    foreground='green')
                cls.msg.grid(row=4, columnspan=3, pady=10)

            # Store cls.filepath in Data
            Data.filepath = cls.filepath

            # Change Upload button to Reupload
            cls.upload_button['text'] = 'Upload File '

    @classmethod
    def run_program(cls):
        """Run optimization program"""

        # Reset the Results class variable
        Results.volume, Results.cost = [], []

        cls.program_text = Label(cls.root, text="Running program...")
        cls.program_text.grid(row=6, columnspan=3)
        cls.root.update()

        cls.root.after(2000)

        try:  # Try Execute
            execute()
        except:  # If failed, display error message and raise Exception
            cls.program_text[
                'text'] = "An error has occured. See the\nterminal for more information"
            cls.program_text['foreground'] = 'red'
            cls.root.after(2000, lambda: cls.program_text.destroy())

            # Raise Exceptions
            raise ProgramError()
        else:
            cls.program_text[
                'text'] = "Program optimized and saved successfully!"
            cls.program_text['foreground'] = 'green'
            cls.root.after(2000, lambda: cls.program_text.destroy())
            cls.msg.destroy()
            cls.upload_button['text'] = 'Upload File '

    @classmethod
    def start(cls):
        """Start the User Interface to Upload File"""
        cls.root = Tk()
        cls.root.title('Optimization Model')
        cls.root.geometry('500x250')

        # Reset filepath
        Data.filepath = ""

        # Upload input file
        upload_text = Label(cls.root, text='Upload Data File')
        upload_text.grid(row=0, column=0, padx=10)

        cls.upload_button = Button(
            cls.root,
            text='Upload File ',
            command=lambda: cls.open_file(),
        )
        cls.upload_button.grid(row=0, column=1)

        upload_message = Label(cls.root, text='',
                               foreground='red').grid(row=4,
                                                      columnspan=2,
                                                      pady=10,
                                                      padx=10)

        # Run optimization and save results
        Results.save_location = 'Results.xlsx'

        # Program prompt
        run_text = Label(cls.root, text="Optimize Program")
        run_text.grid(row=5, column=0, padx=10)

        # Execute button
        run_button = Button(cls.root, text='Execute', command=cls.run_program)
        run_button.grid(row=5, column=1)

        cls.root.mainloop()

        cls.exit_message()