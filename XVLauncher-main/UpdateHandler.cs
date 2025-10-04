using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Diagnostics; // For debug only
using System.Net;
using System.Threading.Tasks;
using XVLauncher.Resources;

namespace XVLauncher
{
    /// <summary>
    /// Class for handling updates with git-based repositories.
    /// </summary>
    public class UpdateHandler
    {
        /// <summary>
        /// The instance of MainWindow that contains GUI elements which show update progress and status.
        /// </summary>
        protected MainWindow Window;
        private WebClient Client;
        private dynamic Res, Commits, Infos;
        private string Link, TargetCommit, Tag;

        /// <summary>
        /// Constructor of the UpdateHandler class.
        /// </summary>
        /// <param name="window">The window where the updater will be called.</param>
        public UpdateHandler(MainWindow window)
        {
            Window = window;
        }

        /// <summary>
        /// Check if it there is a new release on GitHub repo.
        /// </summary>
        /// <returns>true if there is an update available, false otherwise.</returns>
        public async Task<bool> CheckUpdateAvailability()
        {
            if (Properties.Settings.Default.CurrentCommit != (await GetLatestRelease()).Commit)
            {
                Window.infoLabel.Content = "There's an update avaible.";
                return true;
            }
            return false;
        }

        /// <summary>
        /// Compares the currently stored commit id with a target commit id and returns a tuple of list with the old paths and new paths of changed files.
        /// </summary>
        /// <param name="targetCommit">The target commit id using for comparing.</param>
        /// <returns></returns>
        public async Task<(List<string> oldPath, List<string> newPath)> Compare(string targetCommit)
        {
            Window.button.IsEnabled = false;
            // The current latest commit SHA. It should be stored in the Program settings.
            string Current = Properties.Settings.Default.CurrentCommit;
            // The target latest commit SHA. It can be retrieved with the "GetLatestRelease" method.
            string Target = targetCommit;

            // This is the list of items modified between the commits. 
            // Probably all the "oldPaths" should be deleted, whilst all the "newPaths" redownloaded.
            // The list of old paths retrieved.
            List<string> oldPaths = new List<string>();
            // The list of new paths retrieved.
            List<string> newPaths = new List<string>();

            // The url for the API request - GitHub uses owner/repo format
            string api_request = $"https://api.github.com/repos/{Properties.Settings.Default.ProjectID}/compare/{Current}...{Target}?per_page=1000";
            Uri api_request_uri = new Uri(api_request);

            SetUpClient(api_request);

            // Getting the commits list
            Client.DownloadStringCompleted += new DownloadStringCompletedEventHandler(DownloadCommitsListEventHandler);
            await Client.DownloadStringTaskAsync(api_request_uri);
            Client.Dispose();
            SetUpClient(api_request);
            //Getting the id list for the commits found.
            List<string> ids = new List<string>();
            foreach (var c in Commits)
            {
                dynamic val = JsonConvert.DeserializeObject(c.ToString());
                ids.Add(val.id.ToString());
            }
            //Utility for the GUI update.
            int progress = 0;
            int full = ids.Count;
            foreach (var id in ids)
            {
                Debug.WriteLine($"Checking commit {id}");
                int page = 1;
                string url = $"https://api.github.com/repos/{Properties.Settings.Default.ProjectID}/commits/" + id + $"?per_page=1000000&page={page}";
                Client.BaseAddress = url;
                Debug.WriteLine($"Url is: {url}");
                Client.Headers.Add("Content-Type:application/json; charset=utf-8"); //Content-Type  
                Client.Headers.Add("Accept:application/vnd.github+json");
                Client.Headers["Authorization"] = "Bearer " + Properties.Resources.AccessToken;
                //await Client.DownloadStringTaskAsync(api_request_uri);
                Client.DownloadStringCompleted += new DownloadStringCompletedEventHandler(DownloadCommitInfoEventHandler);
                await Client.DownloadStringTaskAsync(url);
                progress++;
                Window.Dispatcher.Invoke(() =>
                {
                    double percentage = (float)progress / full * 100;
                    Window.infoLabel.Content = String.Format("Comparing the differences between the old release and the new one... {0:0.##}%", percentage);
                    Window.UpdateBarProgress(percentage);
                });
                while (Infos.Count > 0)
                {
                    foreach (var info in Infos)
                    {
                        var desInfo = JsonConvert.DeserializeObject(info.ToString());
                        string oldPath = desInfo.old_path.ToString();
                        string newPath = desInfo.new_path.ToString();
                        if ((bool)desInfo.new_file)
                        {
                            if (!newPaths.Contains(newPath))
                                newPaths.Add(newPath);
                        }
                        else if ((bool)desInfo.renamed_file)
                        {
                            if (!newPaths.Contains(newPath))
                                newPaths.Add(newPath);
                            if (newPaths.Contains(oldPath))
                                newPaths.Remove(oldPath);
                            if (!oldPaths.Contains(oldPath))
                                oldPaths.Add(oldPath);
                        }
                        else if ((bool)desInfo.deleted_file)
                        {
                            if (newPaths.Contains(newPath))
                                newPaths.Remove(newPath);
                            if (!oldPaths.Contains(oldPath))
                                oldPaths.Add(oldPath);
                        }
                        else
                        {
                            if (!newPaths.Contains(newPath))
                                newPaths.Add(newPath);
                        }
                    }

                    page += 1;
                    url = $"https://api.github.com/repos/{Properties.Settings.Default.ProjectID}/commits/" + id + $"?per_page=1000000&page={page}";
                    await Client.DownloadStringTaskAsync(url);
                }
            }

            oldPaths.Sort();
            newPaths.Sort();
            string results = "";
            foreach (string s in newPaths)
            {
                results += "\"" + s + "\"" + "\n";
            }
            Window.Dispatcher.Invoke(() =>
            {
                Debug.WriteLine(results);
            });
            Client.Dispose();
            return (oldPaths, newPaths);
        }

        private void SetUpClient(string api_request)
        {

            Client = new WebClient
            {
                BaseAddress = api_request
            };
            Client.Headers.Add("Content-Type:application/json"); //Content-Type  
            Client.Headers.Add("Accept:application/vnd.github+json");
            Client.Headers["Authorization"] = "Bearer " + Properties.Resources.AccessToken;
            Client.Headers["User-Agent"] = "XVLauncher-Pokemon-Projekt2025";
        }

        private void DownloadCommitsListEventHandler(object sender, DownloadStringCompletedEventArgs e)
        {
            if (e.Error != null)
            {
                //TODO: show error on label
                PhpManager.ReportError(e.Error.Message);
            }
            else
            {
                Res = JsonConvert.DeserializeObject(e.Result.ToString());
                Commits = JsonConvert.DeserializeObject(Res.commits.ToString());
            }
        }

        private void DownloadCommitInfoEventHandler(object sender, DownloadStringCompletedEventArgs e)
        {
            if (e.Error != null)
            {
                //TODO: show error on label
                PhpManager.ReportError(e.Error.Message);
            }
            else
            {
                Infos = JsonConvert.DeserializeObject(e.Result.ToString());
            }
        }

        private async Task SetLatestRelease()
        {
            string Url = $"https://api.github.com/repos/{Properties.Settings.Default.ProjectID}/releases/latest";
            string Link = "";
            string TargetCommit = "";
            string Tag = "";
            using (var client = new System.Net.WebClient()) //WebClient  
            {
                client.BaseAddress = Url;
                client.Headers.Add("Content-Type:application/json"); //Content-Type  
                client.Headers.Add("Accept:application/vnd.github+json");
                client.Headers["Authorization"] = "Bearer " + Properties.Resources.AccessToken;
                client.Headers["User-Agent"] = "XVLauncher-Pokemon-Projekt2025";

                // Getting the latest release from GitHub
                dynamic latest = JsonConvert.DeserializeObject(await client.DownloadStringTaskAsync(Url));
                
                TargetCommit = latest.target_commitish.ToString();
                Tag = latest.tag_name.ToString();
                
                //Getting the direct link to the .zip asset of the release (zipball_url)
                Link = latest.zipball_url.ToString();
                string results = latest.ToString();
            }
            this.Link = Link;
            this.TargetCommit = TargetCommit;
            this.Tag = Tag;
        }

        /// <summary>
        /// Retrieves the latest GitHub release informations.
        /// </summary>
        /// <returns>last release download link, last commit name, last release tag.</returns>
        public async Task<(string Link, string Commit, string Tag)> GetLatestRelease()
        {
            if (this.TargetCommit == null)
            {
                await SetLatestRelease();
            }
            return (this.Link, this.TargetCommit, this.Tag);
        }
    }
}

