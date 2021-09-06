Additional customization files that will be copied _after_ the user is created and will be copied _as_ the user.

Permissions will not be `root`. Permissions will be `<uid>:<gid>` of the config user.

This may result in errors for files that the user does not have permission to create.
