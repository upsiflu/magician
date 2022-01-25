# Flupsi's ScryScanner App -- Design considerations.
# Constraints

- Patients (`p`) have an euklidean coordinate (in km) and a seriousness `s` (=pay for touch-healing)
- Every morning, the list of patients is rewritten (scrying pool->JSON), so no state persists across days
- Magician (user) flys a path from tower `(0,0)` back to tower, visiting patients.
    - Speed `v` is 15km/h; segments are straight; healing is assumed zero-time, so `t(segment)=d(p0,p1)/v`
    - A path lies within `tmax=8h`, which means its total length `lmax=120km`
    - It means that any patient farther away than 60km should be removed from the dataset (or, more general, all unreachable `p` at a given existing path)
- We want to have a very high total pay, but we may not need the theoretical maximum.
    - "Allow the magician (user!) to build a valid plan interactively" -- so the magician may want to add a detour for reasons outside my knowledge
    - "Provide help to make the plan efficient, either interactively or automatically" -- any kind of efficiency hint may prove helpful


# User Experience

## MVP

![_You can see a circle around the magician's tower, with clickable patients in the center of a graphical Ui. Left are options, right side has the created path, with a button to `Print` the path._](./assets/UI.jpg)



**View Modes**

- `Scry` and manually enter patient data (fun :-D)
    - either in the space-separated string form or as JSON
    - Should show some helpful messages when mistyping
    - input might be line-based or not
- `Map` the entire 120*120km2 map including little integers for the patient `s`
    - initializes the minimal path (tower -> tower)
    - `Zoom in` (to show patients such that no pair is closer than 1 cm, so that it's clickable -- only available when there is such a case)
- `Print` the path on a new page


**Operations**

(available when patients are displayed at least 1cm apart)

- Select a new p to add to the path by clicking on it
    - Only such p are selectable where the resulting path would not exceed 120km
- Remove the most recent p from the path by clicking on it
- Invert the path (the magician may have reasons to do that; it doesn't affect any parameter)


**Status Display**

(available in `Map` view)

- Length of the path; percentage of 120km; remaining km.
- This is an alternative Viewmode of `Path`


## Convenience

- When (after how many hours) am I here? -- `t=dacc/v`
- Sorting the nodes on screen by worth -- s/d 
    - This can also be done with pairs of patiens (or triplets), then only displaying the ten most wothy options or so. Must consider resources and algorithms; can be optimized for non-optimal, but time-constrained results in the future.
    - Options may be color-coded or shape-coded in order of worthiness
    - `s/d` may give non-optimal results. To some extent, the cumulative worthiness of adjacent patients influences the worthiness of an option for the next visitation. A mathematician may know how to calculate that.
- Scrolling in zoomed-in mode (for accessibility, there should four buttons N, S, W, E)


# Assumptions

These would need consultation with the Countess, but I'll create the prototype based on assumptions :-)

**Population Density / Computing Resources**

A brute-force algorithm might assay all possible combinations. That would be fine if the sick population is low.
So what might the population be? If the density is the same as that of Germany, then the wizard may reach 2.7
million people within a 60km radius. According to [](google.com/search?q=what+percentage+of+people+is+ill), estimates of sickness range from 2% to 95%. That means, we need a better algorithm.

Djakstra's and the A* algorithm, as far as I know, need a grid of streets. Direct flights can connect everyone to everyone, that would be an impossibly large network for the memory (although -- magical computer perhaps?). Since we don't want to crash a computer in our world, neither too far limit the dataset, we don't implement a global shortest-path algorithm.

**Heuristics?**

A direct flight to a distant `p` may be ruled out by heuristics. For example, if the closest `p` is n kilometers away, we don't need to assess any `p` 10n or farther away. In other words, the search circle is reduced to `r=10*n km`.

Is this true though? If all patients with s=9 are in the periphery, then it may be useful to skip close patients that are not exactly on the line. A very rare case, i suspect, even though peripheral patients will see the magician less often than those dwelling near the tower, so their sickness may get more serious. Otoh, a close patient `s=1` will still be worthy visiting because the detour will be minimal.

A* uses a heuristic for maximum cost (or minimum pay). In our case, the fist heuristic would be one patient, `s=1`, at `d=60km`. That includes the whole population within the radius.

There should also be a maximum heuristic. The sum of seriousnesses is limited to the distance between patients.
Since we decided to weed out ps dwelling more than 60km from the tower, we need to calculate each vector's lenght (=distance from tower) anyways.
- If all patients were on a straight line, the maximum pay would be the sum of all seriousnesses.
This is not very helpful.

**Fun instead of Maths!**

Building a graph interactively can serve as a foundation for future optimization helpers. In any case, the wizard will quickly learn to build near-optimal graphs, and will have lots of morning fun doing so, and any potential efficiency increase throught algorithms will be relatively low. Optimizing on an euklidean surface is very suited to human and magician brains.


**Units**

Since there is no braking or accelerating, we only need to model distances, not times.
This means that the Ui will only show a spatial model; times can be derived by multiplication, for convenience.


#Architecture / Libraries

The app is offline-only, so the codebase is very simple. 
- I have included `ianmackenzie`'s geometry library so I don't need to look up all the vector math I've forgotten in the past decade.
- `webbhuset/elm-json-decode` is a continuation-passing style decoder library which I tend to enjoy for its explicitness.

The other libraries I had to include for the Browser platform are listed in the [elm.json](./elm.json) file.


**Tradeoffs**

- I decided not to use any Gui library: Developers don't need abstractions over the `view` because it's really basic for now, and the userbase is {1} and a magician doesn't need a polished interface
- Using the default `Html`, `Css` and `Svg` packages from Elm. The next step will be to use separate files for stylesheets, an `index.html`, some JavaScript class files for custom-elements, parcel or another bundler, a live dev server, perhaps Nix for package and environment management, etc. There are some nice templates for such environments and boilerplate scaffolding. I've not gone down that road because I like how the pure Elm solution has far less files and a single source of truth.
- Concerning components: I decided to implement a single TEA module, Main, that processes all updates to the state. The submodules are not components in the sense of an interface widget, but types, and some of them offer several `ViewMode`s, that is, different widgets representing the same type. For example, the `Path` is `view`ed twice in the `Map` page, once as a map overlay and once as a list with stats.