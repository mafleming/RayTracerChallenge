# RayTracer
Dyalog APL code for the ray tracer described in
**The Ray Tracer Challenge**
*A Test-Driven Guide to Your First 3D Renderer*
by James Buck
from The Pragmatic Programmers
https://pragprog.com/book/jbtracer/the-ray-tracer-challenge

Sincere thanks to Dyalog Ltd. for making available a non-commercial,
personal license of their APL interpreter and environment. APL is certainly
the language of the future, and has been for the last 50 years.

The Ray Tracer code was developed within a set of three Jupyter notebooks,
one for the code itself, another for the tests, and a third for the demo
scenes at the end of each chapter. Tests started in the code notebook and,
once all were passing, were then transferred to the test notebook. The
Jupyter Lab application facilitated the management of these notebooks.

The Jupyter notebook provides a means of describing and documenting the
APL code developed for the ray tracer. More however remains to be done.
For proper packaging and distribution the code needs to be put in its
own Namespace. Doing so will also allow source code management using
SALT in conjunction with Git.

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
+ Precompute matrix inversions
+ Add additional Patterns
+ Multiple light sources
+ Area light source
+ Full Wavefront OBJ file support
+ Scene description language support (YAML?)
