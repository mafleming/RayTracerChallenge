# RayTracer
Dyalog APL code for the ray tracer described in
**The Ray Tracer Challenge**
*A Test-Driven Guide to Your First 3D Renderer*
by James Buck
from The Pragmatic Programmers
https://pragprog.com/book/jbtracer/the-ray-tracer-challenge

Sincere thanks to Dyalog Ltd. for making available a non-commercial,
personal license of their APL interpreter and environment. To learn more
about APL visit tryapl.org for an online interpreter with demos, tutorials,
and more.

The Ray Tracer code was developed within a set of three Jupyter notebooks,
one for the code itself, another for the tests, and a third for the demo
scenes at the end of each chapter. Tests started in the code notebook and,
once all were passing, were then transferred to the test notebook. The
Jupyter Lab application facilitated the management of these notebooks.

## Finished and/or Partial Chapters
+ Chapter  1. Tuples, Points, and Vectors
+ Chapter  2. Drawing on a Canvas
+ Chapter  3. Matrices
+ Chapter  4. Matrix Transforms
+ Chapter  5. Ray-Sphere Intersections
+ Chapter  6. Light and Shading
+ Chapter  7. Making a Scene
+ Chapter  8. Shadows
+ Chapter  9. Planes
+ Chapter 10. Patterns
+ Chapter 11. Reflection and Refraction
+ Chapter 12. Cubes
+ Chapter 13. Cylinders
+ Chapter 14. Groups (heavily modified!)
+ Chapter 15. Triangles (partial)

## Not Yet Attempted
+ Chapter 16. Constructive Solid Geometry

## Planned Enhancements
+ Add additional Patterns
+ Full Wavefront OBJ file support
+ Scene description language support (YAML?)

## Changelog
19-March-2019. Put ray tracer code in its own namespace (RayTracer).
The Test and Demo notebooks have not yet been updated to take this
change into account.

20-March-2019. Fixed issue with reflection overriding transparency
for objects having both attributes.

23-March-2019. Updated the Demo notebook so that the individual
scenes would work with the new arrangement of ray tracer code in
a separate namespace. Updated the code so that the inverse of each
object's transform matrix is precomputed and stored in the object
during scene construction. This results in a speed improvement of
about ten percent.

2-April-2019. Fixed issue with incorrect reflection calculation.
Reflection was only working with Plane objects due to an incorrect
calculation of the reflectv vector in prepare_computations.

6-May-2019. Added support for multiple light sources. Modified the
definition of a point light source so that it can have a radius
from which rays are emitted. Rays are emitted in a normal (Gaussian)
scatter about the light center point.

16-May-2019. Added parallel rendering using isolates. Result is
roughly a 2.5 times speedup on a 4 CPU machine. See new rendering
command llrender. Be sure to "")copy isolate" before running.