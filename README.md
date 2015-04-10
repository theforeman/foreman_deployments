# Foreman Multi-Host Deployments

A plugin adding Foreman Multi-Host Deployment support.


## Design documentation

* [Design](doc/design.md)
* [List of deployment tasks](doc/tasks.md)
* [Examples and usecases](doc/examples.md)
* [User interfaces](doc/user_interfaces.md)
* Other sources:
  * [Redmine tracker](http://projects.theforeman.org/issues/10092)
  * [Deep dive](https://www.youtube.com/watch?v=ISQdESgmOqo) about the task-centric approach ([presentation](https://tstrachota.fedorapeople.org/slides/mhd_presentation/))
  * The original design:
    * Foreman [Deep dive](https://www.youtube.com/watch?v=CFPLGfA6-jU) ([presentation](https://drive.google.com/file/d/0B4ZecfmLdabga0c2SGNqN1ZDQzg/view?usp=sharing))
    * Cfgmgmtcamp [presentation](http://blog.pitr.ch/presentations/2015/cfgmgmtcamp/)
    * Code walk-through [session](https://bluejeans.com/s/83Q9/)


## Installation

Add `gem 'foreman_deployments', path: '../foreman_deployments'` to your `Gemfile.local.rb` file.
For more information see
[How to Install a Plugin](http://projects.theforeman.org/projects/foreman/wiki/How_to_Install_a_Plugin).


## Copyright

Copyright (c) 2014-2015 Red Hat Inc

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

