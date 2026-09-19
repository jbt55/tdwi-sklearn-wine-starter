# TDWI Wine Classifier — Local Agent Lab (Lab 2)

This repository is the starter project for the **local agent** hands-on workshop segment. **Lab content lives in the Jupyter notebook:**

- [`LAB2-Local-Agent-Wine-Classifier.ipynb`](LAB2-Local-Agent-Wine-Classifier.ipynb)

### Lab map

| Step | You do | You learn |
|------|--------|-----------|
| **Setup** ([README](README.md)) | Fork, clone, `.venv` (test push optional) | Your own GitHub repo for the exercise |
| **Lab 2** | Local Cursor agent: requirements → plan → build model + tests → `check.sh` → **create** `/commit-code` → commit | Recipe 1–3: deterministic gates, agent context, slash-command inner loop |

**Contrast with Lab 3:** Lab 3 uses **Cursor Cloud Agents** and GitHub PR Automations; students **create `check.sh` in class**. Lab 2 stays **local**—students **create `/commit-code` in class** (same inner-loop ideas: `check.sh` + sub-agent review).

**After the lab:** [WORKFLOW_RECIPES.md](WORKFLOW_RECIPES.md) — agent workflow framework and adoption path for later recipes.

---

Follow the steps below to fork, clone, and set up Python. **Authenticating local Git and the test push (steps 2 and 6) are optional for now.** If they fail, skip them and open the notebook — do not spend a long time troubleshooting.

---

## 1. Create a GitHub account if you don't have one

If you already have an account, skip to step 2.

1. Go to [GitHub](https://github.com) and create an account.

## 2. Authenticate your local Git to your GitHub account (optional)

Skip this if you already push to GitHub from this machine, or if you want to go straight to fork / clone / `.venv`. You only need a token if you try the optional push in step 6.

Create a **classic** Personal Access Token with the **`repo`** and **`admin:org`** scopes:

1. Sign in to [GitHub](https://github.com)
2. Open your profile menu (top right) → **Settings**
3. In the left sidebar, scroll to **Developer settings** → **Personal access tokens** → **Tokens (classic)**
4. Click **Generate new token** → **Generate new token (classic)**
5. Add a note (e.g. `TDWI workshop`), set an expiration if you like, and check **`repo`** and **`admin:org`**
6. Click **Generate token**, then **copy the token immediately** (you will not see it again). Store it somewhere safe—you will use it as your password when Git prompts you over HTTPS

## 3. Fork the workshop repository

1. Go to the main workshop repo on GitHub:  
   **https://github.com/willjhenry/tdwi-sklearn-wine-starter** *(update when published)*
2. Click **Fork** → **Create a new fork**
3. Click **Create fork** in the lower right

## 4. Clone your fork in Cursor

1. Copy the HTTPS URL from **your** forked repo (**Code** → **HTTPS**, then copy the link)
2. In Cursor, open the Command Palette (**Cmd/Ctrl + Shift + P**) → type: **Git: Clone**
3. Paste the HTTPS URL and clone the repo
4. Select **Open** when asked if you would like to open the cloned repository
5. Select **Open Workspace** when the popup appears in the lower right
6. Reload Cursor so Git and Agent pick up the new folder: Command Palette (**Cmd/Ctrl + Shift + P**) → **Developer: Reload Window**

If Git or Agent still look stuck after you authenticate in step 6, reload again.

## 5. Set up the Python environment (`.venv`)

You need Python 3 installed locally. In Cursor, open a terminal (**Terminal** → **New Terminal**) with the project folder as the working directory, then run the commands for your OS.

**Mac**

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

**Windows** (PowerShell or Command Prompt in the integrated terminal)

```powershell
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

If Windows reports that `python` is not found, try `py -m venv .venv` instead of `python -m venv .venv`.

**Both platforms — select the interpreter in Cursor**

1. Open the Command Palette (**Cmd/Ctrl + Shift + P**) → **Python: Select Interpreter**
2. Choose the interpreter labeled **`.venv`** (path should include `.venv` in this project)

When the venv is active, your terminal prompt usually shows `(.venv)`. You can confirm with `which python` (Mac) or `where python` (Windows)—the path should point inside `.venv`.

## 6. Make your first push (optional)

This checks that you can push from Cursor to **your** fork. It is **optional**. If it fails, skip it and open the notebook — do not spend a long time troubleshooting.

1. Create a test file, `test.txt`. In the file write:  
   `this is just a test file to test committing and pushing`
2. Commit the change in Cursor:
   1. Open the **Source Control** tab in the Primary Side Bar
   2. Press the **+** (plus) to the right of `test.txt` to stage the file
   3. Write a simple commit message in the **Message** input, e.g. `a test commit`
   4. Press the **Commit** button
   5. Press the **Synchronize Changes** button in the lower left corner
   6. If Git prompts for credentials: enter your **GitHub username** and, for the password, paste your **Personal Access Token** (from step 2)—not your GitHub account password

If Git does **not** prompt — or the push fails / goes to the wrong GitHub user — this machine is probably using a cached account. Try **one** of the following with the **same token** from step 2. If neither works quickly, skip the push.

**Clear the saved login, then push again** (uses `git` / the OS credential store — no `gh`)

**Mac:** Open **Keychain Access** (Spotlight) → search `github.com` → delete the internet-password entries for GitHub → **Synchronize Changes** again. When Git prompts, paste the PAT as the password.

**Windows:** Open **Credential Manager** (Start menu) → **Windows Credentials** → remove `git:https://github.com` (and any similar `github.com` entries) → **Synchronize Changes** again. When Git prompts, paste the PAT as the password.

**GitHub CLI (`gh`)** — optional; `gh` is not installed by default. Use this if you already have it, or if you prefer it to Keychain / Credential Manager.

**Mac**

```bash
brew install gh
```

If you do not have Homebrew, download the macOS installer from [cli.github.com](https://cli.github.com/).

**Windows** (PowerShell)

```powershell
winget install --id GitHub.cli
```

If `winget` is not available, download the Windows installer from [cli.github.com](https://cli.github.com/).

Close and reopen the terminal (or Cursor) so `gh` is on your PATH. Confirm with `gh --version` (same command on Mac and Windows).

Then (same on Mac and Windows):

```bash
gh auth login
```

When prompted, choose:

1. **GitHub.com**
2. **HTTPS**
3. **Yes** — authenticate Git with your GitHub credentials
4. **Paste an authentication token** — paste the Personal Access Token from step 2 (not a browser login)

Confirm the active account:

```bash
gh auth status
```

If the wrong user is active (for example work vs personal), switch:

```bash
gh auth switch --user YOUR_GITHUB_USERNAME
```

Then run `gh auth status` again. If that username is not listed, run `gh auth login` again and paste the token for that account, then switch.

If Git still uses the old account, run:

```bash
gh auth setup-git
```

Then try **Synchronize Changes** again. Reload Cursor afterward (**Developer: Reload Window**) so Git picks up the new login.

---

After setup, open [`LAB2-Local-Agent-Wine-Classifier.ipynb`](LAB2-Local-Agent-Wine-Classifier.ipynb).
