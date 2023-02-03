# DataDrivenMicroscopy

## Running

```bash
./bin/dev/doctor
```

the `doctor` script checks your setup and suggests the next steps until you are
ready to run the application. It copies suggested commands to the clipboard.
The setup process consists of running `./bin/dev/doctor` and then pasting and
running the suggested command until your server is running.

In development mode, the server will be running on [`localhost:4000`](http://localhost:4000).


To add a default Admin: "mix run priv/repo/seeds.exs" 
email: admin@admin.com, password: 1234567890
