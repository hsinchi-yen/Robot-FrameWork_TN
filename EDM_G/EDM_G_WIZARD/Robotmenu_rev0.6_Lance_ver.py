import os
import re
import subprocess
import tkinter as tk
from tkinter import messagebox, filedialog, simpledialog
from tkinter import ttk
from robot.api import TestSuiteBuilder
import time
import threading
import paramiko

class RobotTestRunner:
    def __init__(self, root):
        self.root = root
        self.root.title("Robot Framework Test Runner")
        self.ssh = paramiko.SSHClient()
        self.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.ssh.connect("10.88.89.105", username='root', password='', allow_agent=False, look_for_keys=False)
        
        
        self.test_cases = []
        self.test_file_paths = []
        self.test_results = {}

        self.create_widgets()

    def create_widgets(self):
      
        self.title_label = tk.Label(self.root, text="Please Load Cases first", font=("Arial", 20, "bold"))
        self.title_label.pack(pady=10)
        # Main frame
        main_frame = tk.Frame(self.root)
        main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Right frame for buttons
        self.right_frame = tk.Frame(main_frame)
        self.right_frame.pack(side=tk.RIGHT, fill=tk.Y)
        
        # Read DCOUT1 initial GPIO state
        # initial_state1 = self.get_DCOUT1_state()
        # DCOUT1_button_text = "DCOUT1 ON" if initial_state1 == 1 else "DCOUT1 OFF"
        # DCOUT1_button_color = "green" if initial_state1 == 1  else "red"
        # Read DCOUT2 initial GPIO state
        # initial_state2 = self.get_DCOUT2_state()
        # DCOUT2_button_text = "DCOUT2 ON" if initial_state2 == 1 else "DCOUT2 OFF"
        # DCOUT2_button_color = "green" if initial_state2 == 1  else "red"
        
        # DCOUT1 button
        self.dcout1_button = tk.Button(self.right_frame, text="DCOUT1",font=("Arial", 8), width=8, command=self.toggle_dcout1)
        self.dcout1_button.pack(pady=5)
        # DCOUT2 button
        self.dcout2_button = tk.Button(self.right_frame, text="DCOUT2", font=("Arial", 8), width=8, command=self.toggle_dcout2)
        self.dcout2_button.pack(pady=5)
        
        # Treeview frame (left side)
        tree_frame = tk.Frame(main_frame)
        tree_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        self.tree = ttk.Treeview(tree_frame, columns=("Select", "Test Case", "Tags", "Documentation", "Result", "Time"), show='headings', height=15)
        self.tree.heading("Select", text="Select", anchor="center")
        self.tree.heading("Test Case", text="Test Case", anchor="w")
        self.tree.heading("Tags", text="Tags", anchor="w")
        self.tree.heading("Documentation", text="Documentation", anchor="w")
        self.tree.heading("Result", text="Result", anchor="w")
        self.tree.heading("Time", text="Time (s)", anchor="w")

        self.tree.column("Select", width=80, anchor='center', stretch=tk.NO)
        self.tree.column("Time", width=70, anchor='center')

        for col in ("Test Case", "Tags", "Documentation", "Result", "Time"):
            self.tree.column(col, anchor='w')

        self.tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        # Scrollbars for treeview
        self.vsb = ttk.Scrollbar(tree_frame, orient="vertical", command=self.tree.yview)
        self.vsb.pack(side=tk.RIGHT, fill=tk.Y)
        self.tree.configure(yscrollcommand=self.vsb.set)

         # Buttons and statistics frame (right side)
        self.button_stats_frame = tk.Frame(main_frame)
        self.button_stats_frame.pack(side=tk.RIGHT, fill=tk.Y, padx=(10, 0))

        self.load_button = tk.Button(self.button_stats_frame, text="Load Test Cases", command=self.load_test_cases)
        self.load_button.pack(anchor=tk.W, pady=5)

        self.run_all_button = tk.Button(self.button_stats_frame, text="Run All Tests", command=self.run_all_tests)
        self.run_all_button.pack(anchor=tk.W, pady=5)

        self.run_selected_button = tk.Button(self.button_stats_frame, text="Run Selected Tests", command=self.run_selected_tests)
        self.run_selected_button.pack(anchor=tk.W, pady=5)

        self.view_report_button = tk.Button(self.button_stats_frame, text="View Test Report", command=self.view_test_report)
        self.view_report_button.pack(anchor=tk.W, pady=5)
        self.reset_select_cases = tk.Button(self.button_stats_frame, text="Reset selected cases", command=self.reset_all_selections)
        self.reset_select_cases.pack(anchor=tk.W, pady=5)
        # Statistics labels
        self.total_label = tk.Label(self.button_stats_frame, text="Total Cases: 0")
        self.total_label.pack(anchor=tk.W,pady=(80, 0))
        self.selected_label = tk.Label(self.button_stats_frame, text="Selected Cases: 0")
        self.selected_label.pack(anchor=tk.W)  # Add some padding to separate buttons and labels

        self.pass_label = tk.Label(self.button_stats_frame, text="Passed: 0")
        self.pass_label.pack(anchor=tk.W,pady=(10, 0))

        self.fail_label = tk.Label(self.button_stats_frame, text="Failed: 0")
        self.fail_label.pack(anchor=tk.W)

        self.rate_label = tk.Label(self.button_stats_frame, text="Pass Rate: 0.00%")
        self.rate_label.pack(anchor=tk.W)

        self.total_time_label = tk.Label(self.button_stats_frame, text="Total Time: 0s")
        self.total_time_label.pack(anchor=tk.W, pady=(10, 50))

        
        # Variable info frame for Variable list
        self.variable_info_frame = tk.Frame(self.button_stats_frame)
        self.variable_info_frame.pack(anchor=tk.W)

        # Bind selection event
        self.tree.bind("<Button-1>", self.on_click) 
        
    def get_DCOUT1_state(self):
        
        stdin, stdout, stderr = self.ssh.exec_command('gpioget gpiochip2 16')  # the command will pull GPIO high , if state is OFF , then it will turn ON 
        state = stdout.read().decode().strip()
        #print('get state:',state)
        return int(state)  
    
    def get_DCOUT2_state(self):
      
        stdin, stdout, stderr = self.ssh.exec_command('gpioget gpiochip2 6')
        state = stdout.read().decode().strip()
        return int(state)
    
    def toggle_dcout1(self):
        current_state = self.dcout1_button.cget('text').split()[-1]
        #print ('debug:',current_state)
        if current_state == 'OFF':
            self.dcout1_button.config(text='DCOUT1 ON', bg='green')
            self.ssh_command('./DOUT_CTRL.sh ON')
        else:
            self.dcout1_button.config(text='DCOUT1 OFF',bg='red')
            self.ssh_command('./DOUT_CTRL.sh OFF')
        
        
    def toggle_dcout2(self):
        current_state = self.dcout2_button.cget('text').split()[-1]
        if current_state == 'OFF':
            self.dcout2_button.config(text='DCOUT2 ON', bg='green')
            self.ssh_command('gpioset gpiochip2 6=1')
        else:
            self.dcout2_button.config(text='DCOUT2 OFF', bg='red')
            self.ssh_command('gpioset gpiochip2 6=0')
    def ssh_command(self, command):
        stdin, stdout, stderr = self.ssh.exec_command(command)
        print(stdout.read().decode())
        print(stderr.read().decode())

    def __del__(self):
        self.ssh.close()
        
        
    def on_click(self, event):
        region = self.tree.identify("region", event.x, event.y)
        if region == "cell":
            column = self.tree.identify_column(event.x)
            if column == "#1":  # Select column
                item = self.tree.identify_row(event.y)
                current_state = self.tree.set(item, "Select")
                new_state = "✓" if current_state != "✓" else ""
                self.tree.set(item, "Select", new_state)
        self.update_stats()
    def reset_all_selections(self):
        for item in self.tree.get_children():
            if self.tree.set(item, "Select") == "✓":
             self.tree.set(item, "Select", "")
        self.update_stats() 
    def clear_variable_info(self):
    # Fucntion for clearing the info when load another robot file
        for widget in self.variable_info_frame.winfo_children():
            widget.destroy()
            
    def load_test_cases(self):
        # Reset the info
        self.clear_variable_info()
        
        self.test_file_path = filedialog.askopenfilename(title="Select Robot Test File", filetypes=[("Robot Files", "*.robot")])
        if not self.test_file_path:
            return
        self.test_file_paths.append(self.test_file_path)
        
        for i in self.tree.get_children():
            self.tree.delete(i)
        self.test_cases = []
        self.test_results = {}

        suite = TestSuiteBuilder().build(self.test_file_path)
        self.title_label.config(text=suite.name)
        for test in suite.tests:
            case_name = test.name
            case_tags = ', '.join(test.tags)
            case_doc = test.doc
            self.tree.insert("", "end", values=("", case_name, case_tags, case_doc, "Not Run"))
            self.test_cases.append((case_name, case_tags, case_doc))
        
        self.Variable_label = tk.Label(self.variable_info_frame, text="===========Variable List===========", font=("Arial", 12))
        self.Variable_label.pack(anchor=tk.W) 
        # Find path /Resources/Common_Params.robot 
        test_dir = os.path.dirname(self.test_file_path)
        parent_dir = os.path.dirname(test_dir)
        self.common_params_path = os.path.join(parent_dir, "Resources", "Common_Params.robot")
    
        if os.path.exists(self.common_params_path):
            self.variables_entries = {}
            within_variables_section = False

            with open(self.common_params_path, 'r') as file:
                for line in file:
                    stripped_line = line.strip()

                # stop to read until *** Keywords *** part
                    if stripped_line.startswith("*** Keywords ***"):
                        break

                # Check whether *** Variables *** in section
                    if stripped_line.startswith("*** Variables ***"):
                        within_variables_section = True
                        continue

                # if *** Variables *** existed，handle striped lines
                    if within_variables_section:
                    # ignore comment
                        if stripped_line.startswith("#"):
                            continue
                    
                    # Find variable values with re
                        match = re.match(r'^\$\{(.+?)\}\s*(.+)', stripped_line)
                        
                        
                        if match:
                            
                            var_name, var_value = match.groups()
                            
                            var_frame = tk.Frame(self.variable_info_frame)
                            var_frame.pack(anchor="w", padx=1, pady=1, fill=tk.X)
                            label = tk.Label(var_frame, text=var_name)
                            label.pack(side=tk.LEFT)

                            
                            entry = tk.Entry(var_frame, width=20)
                            entry.insert(0, var_value)
                            entry.pack(side=tk.RIGHT)

                            self.variables_entries[var_name] = entry
                
            # added save button
            save_button = tk.Button(self.variable_info_frame, text="Save Variables", command=self.save_variables)
            save_button.pack(anchor=tk.W) 
        self.update_stats()
    
    def save_variables(self):
    # Get the info with Entry
        updated_variables = {}
        for var_name, entry in self.variables_entries.items():
            updated_variables[var_name] = entry.get()

    # Read file and replace
        with open(self.common_params_path, 'r') as file:
            lines = file.readlines()

        with open(self.common_params_path, 'w') as file:
            within_variables_section = False

            for line in lines:
                stripped_line = line.strip()

            # stop to read until *** Keywords *** part
                if stripped_line.startswith("*** Keywords ***"):
                    within_variables_section = False

            # if *** Variables *** existed，handle striped lines
                if stripped_line.startswith("*** Variables ***"):
                    within_variables_section = True

            # Find variable values with re
                if within_variables_section:
                    match = re.match(r'^\$\{(.+?)\}\s*(.+)', stripped_line)
                    if match:
                        var_name = match.group(1)
                        if var_name in updated_variables:
                             line = f"${{{var_name}}}    {updated_variables[var_name]}\n"
                
                file.write(line)
            
    def run_all_tests(self):
        self.disable_ui()

        all_items = self.tree.get_children()
        self.run_tests([self.tree.item(item)["values"][1] for item in all_items], all_items)

        self.enable_ui()

    def run_selected_tests(self):
        self.disable_ui()
        # self.pass_count = 0
        # self.fail_count = 0
        # self.total_execution_time = 0
        # self.update_stats()
        # self.root.update()
        selected_items = [item for item in self.tree.get_children() if self.tree.set(item, "Select") == "✓"]
        selected_cases = [self.tree.item(item)["values"][1] for item in selected_items]
        if not selected_cases:
            messagebox.showwarning("No Selection", "Please select at least one test case.")
            self.enable_ui()
            return

        self.run_tests_thread(selected_cases, selected_items)
        
    def run_tests_thread(self, cases, items):
            # Run the tests in a separate thread to avoid blocking the UI
            threading.Thread(target=self.run_tests, args=(cases, items)).start()
    def run_tests(self, cases, items):
        
        if not self.test_file_path:
            messagebox.showwarning("No Test File", "Please load a Robot test file first.")
            return

        # script_name = os.path.splitext(os.path.basename(self.test_file_path))[0]
        # log_folder = os.path.join(os.path.dirname(self.test_file_path), script_name)
        result_folder = os.path.join(os.path.dirname(os.path.dirname(self.test_file_path)), "Result")
        if os.path.exists(result_folder):
                if messagebox.askyesno(title="Folder exist",message="Do you want to delete it?"):
                    subprocess.run(["rm", "-rf", result_folder])
                else:
                    messagebox.showinfo("Info", f"The existing folder {result_folder} will be used.")
        os.makedirs(result_folder, exist_ok=True)
        total_execution_time = 0
        for i, case in enumerate(cases):
            self.tree.set(items[i], column="Result", value="In Progress")
            self.tree.item(items[i], tags=("inprogress",))
            self.tree.tag_configure("inprogress", background="yellow")
            self.root.update()
            #The part for result folders : Case+ Documentation + timestamp
            case_doc = self.tree.item(items[i])["values"][3]  # Get Documentation
            case_doc = case_doc.replace("/", "_")   #Take place "/" to "_"
            timestamp = time.strftime("%Y%m%d_%H%M%S")
            case_folder_name = f"{case}_{case_doc}_{timestamp}"
            case_folder = os.path.join(result_folder, case_folder_name)

            start_time = time.time()
            result = subprocess.run(["robot", "-t", case, "-d", case_folder, self.test_file_path], capture_output=False, text=True)\
            
            end_time = time.time()
            execution_time = int(end_time - start_time)  
            total_execution_time += execution_time

            result_text = "PASS" if result.returncode == 0 else "FAIL"
            self.tree.set(items[i], column="Result", value=result_text)
            self.tree.set(items[i], column="Time", value=str(execution_time))
            self.tree.item(items[i], tags=(result_text.lower(),))
            self.test_results[case] = result.stdout

            self.update_stats()
            self.root.update()

            self.tree.tag_configure("pass", background="light green")
            self.tree.tag_configure("fail", background="light coral")
        self.total_time_label.config(text=f"Total Time: {self.format_time(total_execution_time)}")
        self.enable_ui()
        
        
    def format_time(self, seconds):
        days, seconds = divmod(seconds, 86400)
        hours, seconds = divmod(seconds, 3600)
        minutes, seconds = divmod(seconds, 60)
        return f"{days}d {hours}h {minutes}m {seconds}s"   
     
    def disable_ui(self):
        self.load_button.config(state=tk.DISABLED)
        self.run_all_button.config(state=tk.DISABLED)
        self.run_selected_button.config(state=tk.DISABLED)
        self.view_report_button.config(state=tk.DISABLED)
        #self.vsb.pack_forget()
        self.tree.unbind("<Button-1>")

    def enable_ui(self):
        self.load_button.config(state=tk.NORMAL)
        self.run_all_button.config(state=tk.NORMAL)
        self.run_selected_button.config(state=tk.NORMAL)
        self.view_report_button.config(state=tk.NORMAL)
        self.vsb.pack(side=tk.RIGHT, fill=tk.Y)
        self.tree.bind("<Button-1>", self.on_click)
    
    def update_stats(self):
        total_cases = len(self.test_cases)
        selected_cases = sum(1 for item in self.tree.get_children() if self.tree.set(item, "Select") == "✓")
        pass_count = sum(1 for item in self.tree.get_children() if self.tree.item(item)['values'][4] == "PASS")
        fail_count = sum(1 for item in self.tree.get_children() if self.tree.item(item)['values'][4] == "FAIL")
        pass_rate = (pass_count / total_cases) * 100 if total_cases > 0 else 0

        self.total_label.config(text=f"Total Cases: {total_cases}")
        self.selected_label.config(text=f"Selected Cases: {selected_cases}")
        self.pass_label.config(text=f"Passed: {pass_count}")
        self.fail_label.config(text=f"Failed: {fail_count}")
        self.rate_label.config(text=f"Pass Rate: {pass_rate:.2f}%")

    def view_test_report(self):
        selected_items = [item for item in self.tree.get_children() if self.tree.set(item, "Select") == "✓"]
        if not selected_items:
            messagebox.showwarning("No Selection", "Please select a test case to view its report.")
            return

        report_window = tk.Toplevel(self.root)
        report_window.title("Test Reports")
        report_text = tk.Text(report_window, wrap=tk.WORD)
        report_text.pack(fill=tk.BOTH, expand=True)

        for item in selected_items:
            case_name = self.tree.item(item)["values"][1]
            if case_name in self.test_results:
                #report_text.insert(tk.END, f"=== Test Report: {case_name} ===\n")
                report_text.insert(tk.END, self.test_results[case_name])
                report_text.insert(tk.END, "\n\n")
            else:
                report_text.insert(tk.END, f"No report available for {case_name}. Please run the test first.\n\n")

        report_text.config(state=tk.DISABLED)

if __name__ == "__main__":
    root = tk.Tk()
    app = RobotTestRunner(root)
    root.mainloop()
