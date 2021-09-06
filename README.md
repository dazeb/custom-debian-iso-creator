# Custom Debian ISO Creator

Scripts I use for Debian home WiFi penetration testing, deploying/downloading Linux and other operating systems, and other ad-hoc linux utility functionality like formatting disks or resetting Windows passwords on old drives.

See [Create a Custom Debian Live Environment (CD or USB)](https://willhaley.com/blog/custom-debian-live-environment/) for further discussion.

## Run

Copy the `sample-config.yaml` to `config.yaml` and update as needed.

```
# Build the docker image, run it, and start a shell.
./run.sh
```

```
# Generate ISO.
docker:$ ./generate.py
```

## Customization

* `custom-system-files` add any files here in the desired output directory stucture (e.g. `custom-system-files/etc/whatever/whatever.conf`). These files will be copied as `root` before `apt` is run in the `chroot` environment.
* `custom-user-files` add any files here in the desired output directory structure (e.g. `custom-user-files/home/myuser/file.txt`). These filles will be copied as the `<user>` as defined in `config.yaml` and will be copied after `apt` has run in the `chroot` and the user account was created.

## Utilities

Some of the installed applications (transmission-gtk for BitTorrent, reaver, aircrack, hashcat, etc.) in this repo may raise a few eyebrows. There is nothing wrong with using these tools for research purposes.

I think it is interesting and a great learning experience for future security researchers or computer hobbyists to try "hacking" one's own WiFi network to understand how weak or strong their home security truly is and how networking security protocols function.

See references and related materials from well-known univerities.

* https://rtg.cis.upenn.edu/cis700-002/talks/Aircrack-Reaver-Fern.pdf
* https://super.cs.uchicago.edu/usable17/crackingtutorial.html
* https://tagteam.harvard.edu/hub_feeds/4158/feed_items/2535345
* http://people.oregonstate.edu/~marshaby/OSUSIM_Project_Writeups/2018_AirCrackNG/AirCrackNG.html
* https://courses.cs.washington.edu/courses/cse484/15sp/slides/484Lecture-Wireless-Hacking.pdf
* https://core.ac.uk/download/pdf/80993616.pdf
* https://courses.engr.illinois.edu/cs461/fa2015/static/proj3_2.pdf
* http://www-scf.usc.edu/~csci530l/instructions/lab-authentication-instructions-hashcat.htm
* https://www.cs.usfca.edu/~ejung/courses/686/lab1.html
* http://mirrors.mit.edu/parrot/misc/openbooks/security/HHS_en11_Hacking_Passwords.v2.pdf
* https://courses.csail.mit.edu/6.857/2016/files/9.pdf
* http://www.scs.stanford.edu/~sorbo/bittau-wep-slides.pdf

Just like criminal justice, psychology, philosophy, art, mechnical engineering, mathematics, health, astrophysics, or just about any other discipline may ask "what if" or "let me test these understood assumptions", so does computer science, and the utilities included in these scripts exist for that purpose.
