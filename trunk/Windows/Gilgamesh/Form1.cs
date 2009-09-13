using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
//using System.Linq;
using System.Text;
using System.Windows.Forms;

using Gilgamesh.Properties;

namespace Gilgamesh {
    public partial class Preferences: Form {
        private String resourcePath;
        private String loginScript;
        private Icon upIcon;
        private Icon downIcon;
        private bool successful;

        public Preferences() {
            InitializeComponent();

            successful=false;

            this.Closing+=new CancelEventHandler(handle_Close);

            preferencesMenuItem.Click+=new EventHandler(preferences_Click);
            refreshMenuItem.Click+=new EventHandler(refresh_Click);
            aboutMenuItem.Click+=new EventHandler(about_Click);
            quitMenuItem.Click+=new EventHandler(quit_Click);

            resourcePath=Application.StartupPath+"\\";

            loginScript=resourcePath+"uac_login.exe";
            upIcon=new System.Drawing.Icon(resourcePath+"up.ico");
            downIcon=new System.Drawing.Icon(resourcePath+"down.ico");

            if (Settings.Default.firstTime) {
                Settings.Default.firstTime=false;
                Settings.Default.Save();
                Show();
            }
            else {
                login();
            }

            timer.Tick+=new EventHandler(timer_Tick);
            timer.Interval=System.Convert.ToInt32(Settings.Default.wait);
            timer.Enabled=true;
            timer.Start();
        }

        private void Form1_Load(object sender, EventArgs e) { }

        void handle_Close(object sender, CancelEventArgs e) {
            e.Cancel=true;
            Hide();
        }

        void timer_Tick(object sender, EventArgs e) {
            login();
        }

        void preferences_Click(object sender, EventArgs e) {
            Show();
        }

        private void apply_Click(object sender, EventArgs e) {
            Settings.Default.Save();

            Cursor.Current=Cursors.WaitCursor;

            login();

            Cursor.Current=Cursors.Arrow;

            if (successful) {
                applyButton.Text="Success";
                applyButton.Enabled=false;
            }
        }

        void refresh_Click(object sender, EventArgs e) {
            login();
        }

        private void about_Click(object sender, EventArgs e) {
            AboutBox a=new AboutBox();
            a.Show();
        }

        private void quit_Click(object sender, EventArgs e) {
            notifyIcon.Dispose();
            Application.Exit();
        }

        private void login() {
            String args=String.Format(
                "\"{0:G}\" \"{1:G}\" \"{2:G}\" \"{3:G}\" \"{4:G}\" \"{5:G}\"",
                Settings.Default.url,
                Settings.Default.useragent,
                Settings.Default.success,
                Settings.Default.timeout,
                Settings.Default.username,
                Settings.Default.password
            );

            System.Diagnostics.Process proc=new System.Diagnostics.Process();
            proc.StartInfo.WindowStyle=System.Diagnostics.ProcessWindowStyle.Hidden;
            proc.StartInfo.FileName=loginScript;
            proc.StartInfo.Arguments=args;
            proc.Start();
            proc.WaitForExit();
            int state=proc.ExitCode;

            if (state==0) {
                notifyIcon.Icon=upIcon;
                successful=true;
            }
            else {
                notifyIcon.Icon=downIcon;
                successful=false;
            }
        }
    }
}
