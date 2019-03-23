:Namespace RayTracer
⍝ === VARIABLES ===

EPSILON←0.00001

EVAL_REFLECTION←1

EVAL_REFRACTION←1

FALSE←0

INFINITY←9.9E99

MAX_RECURSION←5

TRUE←1

black←3⍴0

blue←0 0 1

camera_fview←3

camera_halfh←8

camera_halfw←7

camera_hsize←1

camera_inverse←5

camera_psize←6

camera_transform←4

camera_vsize←2

cone_closed←7

cone_maximum←6

cone_minimum←5

cyan←0 1 1

cylinder_closed←7

cylinder_maximum←6

cylinder_minimum←5

green←0 1 0

group_members←4

hit_distance←2

hit_eyev←4

hit_inside←6

hit_n1←10

hit_n2←11

hit_normalv←5

hit_object←1

hit_overpt←8

hit_point←3

hit_reflectv←7

hit_underpt←9

light_color←2

light_point←1

magenta←1 0 1

material_ambient←2

material_color←1

material_diffuse←3

material_pattern←1

material_reflective←6

material_refractive←7

material_shininess←5

material_specular←4

material_transparency←8

obj_inverse←3

obj_material←4

obj_tag←1

obj_transform←2

pat_checker←4

pat_gradient←2

pat_ring←3

pat_stripe←1

pat_test←0

pattern_color1←4

pattern_color2←5

pattern_inverse←3

pattern_transform←2

pattern_type←1

ray_direction←2

ray_origin←1

red←1 0 0

shape_cone←5

shape_cube←3

shape_cylinder←4

shape_group←6

shape_plane←2

shape_smtriangle←8

shape_sphere←1

shape_test←0

shape_triangle←7

triangle_edges←6

triangle_normal←7

triangle_points←5

white←3⍴1

yellow←1 1 0


⍝ === End of variables definition ===

(⎕IO ⎕ML ⎕WX)←1 1 3

∇ r←text PutText name;tn
          ⍝ Write text to file (must be single byte text)
     
 :Trap 0
     tn←name ⎕NCREATE 0
 :Else
     tn←name ⎕NTIE 0
     0 ⎕NRESIZE tn
 :EndTrap
     
 r←text ⎕NAPPEND tn(⎕DR' ')
 ⎕NUNTIE tn
∇

 add_pattern_transform←{
       ⍝ pattern  pattern_transform  pattern → pattern
     p←⍺
     p[pattern_transform]←⊂⍵
     p[pattern_inverse]←⊂⌹⍵
     p
 }

 add_shape_transform←{
       ⍝ pattern  pattern_transform  pattern → pattern
     s←⍺
     s[obj_transform]←⊂⍵
     s[obj_inverse]←⊂⌹⍵
     s
 }

∇ Z←camera W;half_view;aspect;halfh;halfv;psize
        ⍝ camera  hsize vsize field_of_view → camera_structure
 (hsize vsize fview)←W
 Z←hsize vsize fview(identity 4)(identity 4)
 half_view←3○0.5×fview
 aspect←hsize÷vsize
 :If aspect≥1
     halfw←half_view
     halfh←half_view÷aspect
 :Else
     halfw←half_view×aspect
     halfh←half_view
 :EndIf
 psize←2×halfw÷hsize
 Z←Z,psize,halfw,halfh
∇

 canvas←{(1↓⍵)⍴⊂(1↑⍵)⍴⊂0 0 0}

 canvas_to_ppm←{
        ⍝ Truncate negative numbers to zero, limit maximum to 255
     nums←⊃,/⊃,/255⌊⌈255×0⌈⍵
     shape←(⌊(⍴nums)÷15),15
     head←4 0⍕shape⍴nums
     tail←4 0⍕(-(⍴nums)-×/shape)↑nums
        ⍝ Must transpose ⍴⍵ to get width/height from columns/rows
     0=⍴tail:4 1⍴'P3'(⍕(⍴⊃⍵[1]),⍴⍵)'255'head
     5 1⍴'P3'(⍕(⍴⊃⍵[1]),⍴⍵)'255'head tail
 }

 check_axis←{
       ⍝ check_axis  numeric numeric → numeric numeric
     (o d)←⍵
     EPSILON>|d:(INFINITY×¯1-o)(INFINITY×1-o)
     tmin←(¯1-o)÷d
     tmax←(1-o)÷d
     tmin>tmax:tmax tmin
     tmin tmax
 }

 check_cap←{
       ⍝ ray  check_cap  distance → Boolean
       ⍝ x← (1⌷⊃⍺[ray_origin]) + ⍵×1⌷⊃⍺[ray_direction]
       ⍝ z← (3⌷⊃⍺[ray_origin]) + ⍵×3⌷⊃⍺[ray_direction]
     x←(ray_origin 1⊃⍺)+⍵×ray_direction 1⊃⍺
     z←(ray_origin 3⊃⍺)+⍵×ray_direction 3⊃⍺
     1≥(x×x)+z×z
 }

 check_cap2←{
       ⍝ ray  check_cap2  distance radius → Boolean
     (d r)←⍵
       ⍝ x← (1⌷⊃⍺[ray_origin]) + d×1⌷⊃⍺[ray_direction]
       ⍝ z← (3⌷⊃⍺[ray_origin]) + d×3⌷⊃⍺[ray_direction]
     x←(ray_origin 1⊃⍺)+d×ray_direction 1⊃⍺
     z←(ray_origin 3⊃⍺)+d×ray_direction 3⊃⍺
     (r×r)≥(x×x)+z×z
 }

 checker_pattern←{pat_checker identity4 identity4 ⍺ ⍵}

 color_at←{
        ⍝ world  color_at  ray remaining → color
     (wray remaining)←⍵
     inter←⍺ intersect_world wray
        ⍝ Return black if no intersections
        ⍝ 0=≢inter: 0 0 0
        ⍝ Take first positive intersection as the hit
     h←hit inter
        ⍝ Return black if no hit
     0=≢h:0 0 0
     comps←h prepare_computations wray
     comps←comps compute_n1n2 inter h
     ⍺ shade_hit comps remaining
 }

∇ Z←COMPS compute_n1n2 ARGS;XS;H;i;con;p;obj;last
       ⍝ COMPS  compute_n1n2  XS HIT → COMPS
       ⍝ Compute the n1 and n2 attributes
       ⍝ for a result returned by prepare_computations
       ⍝ Use immediately after prepare_computations
 (XS H)←ARGS
 Z←COMPS
 :If ~EVAL_REFRACTION
     :Return
 :EndIf
 con←⍬
 :For i :In XS
     obj←⊃i
         ⍝ Compute n1
     :If H≡i
         :If 0=≢con
             Z[hit_n1]←1
         :Else
             last←⊃¯1↑con
             Z[hit_n1]←⊂obj_material material_refractive⊃last
         :EndIf
     :EndIf
         ⍝ container and hit
     :If ⍬≡con
         con←⊂obj  ⍝ containers empty
     :Else
         p←con∊⊂obj  ⍝ see if object already in container
         :If 0=∨/p
             con,←⊂obj
         :Else
             con←(~p)/con
         :EndIf
     :EndIf
         ⍝ Compute n2
     :If H≡i
         :If 0=≢con
             Z[hit_n2]←1
         :Else
             last←⊃¯1↑con
             Z[hit_n2]←⊂obj_material material_refractive⊃last
         :EndIf
         :Leave
     :EndIf
 :EndFor
∇

∇ Z←cone
 Z←shape_cone identity4 identity4 material(¯1×INFINITY)INFINITY FALSE
∇

∇ Z←C cone_intersect R;a;b;c;disc;t0;t1;y0;y1;t
       ⍝ cone  cone_intersect  ray → ⍬ or intersection intersection
 Z←⍬
 a←-/(⊃R[ray_direction])*2
 b←-/2×(⊃R[ray_origin])×⊃R[ray_direction]
 c←⊃R[ray_origin]
 c←-/c[1 2 3]*2
 :If (EPSILON>|a)∧EPSILON<|b
     t←-c÷2×b
     Z←⊂C intersection t
         ⍝Z← Z,Z
 :ElseIf EPSILON<|a
     disc←(b*2)-4×a×c
     :If 0≤disc
         t0←((-b)-disc*0.5)÷2×a
         t1←((-b)+disc*0.5)÷2×a
         :If t0>t1
             t0 t1←t1 t0
         :EndIf
           ⍝ y0← (2⌷⊃R[ray_origin])+t0×2⌷⊃R[ray_direction]
         y0←(ray_origin 2⊃R)+t0×ray_direction 2⊃R
         :If (y0>C[cone_minimum])∧y0<C[cone_maximum]
             Z←⊂C intersection t0
         :EndIf
           ⍝ y1← (2⌷⊃R[ray_origin])+t1×2⌷⊃R[ray_direction]
         y1←(ray_origin 2⊃R)+t1×ray_direction 2⊃R
         :If (y1>C[cone_minimum])∧y1<C[cone_maximum]
             Z←Z,⊂C intersection t1
         :EndIf
     :EndIf
 :EndIf
       ⍝ Check for intersection with caps of closed cylinder
       ⍝ :If C[cone_closed]^(EPSILON<|2⌷⊃R[ray_direction])
 :If C[cone_closed]∧(EPSILON<|ray_direction 2⊃R)
         ⍝ t← (C[cone_minimum]-2⌷⊃R[ray_origin])÷2⌷⊃R[ray_direction]
     t←(C[cone_minimum]-ray_origin 2⊃R)÷ray_direction 2⊃R
     :If R check_cap2 t,C[cone_minimum]
         Z←Z,⊂C intersection t
     :EndIf
         ⍝ t← (C[cone_maximum]-2⌷⊃R[ray_origin])÷2⌷⊃R[ray_direction]
     t←(C[cone_maximum]-ray_origin 2⊃R)÷ray_direction 2⊃R
     :If R check_cap2 t,C[cone_maximum]
         Z←Z,⊂C intersection t
     :EndIf
 :EndIf
 :If 1=≢Z
     Z←Z,Z
 :EndIf
       ⍝ I also need to make sure the list is sorted by distance
 :If Z≢⍬
     t←2⌷¨Z
     Z←Z[⍋t]
 :EndIf
∇

 cone_normal_at←{
       ⍝ cone  cone_normal_at  point → vector
     dist←(⍵[1]*2)+⍵[3]*2
     (1>dist)∧⍵[2]≥⍺[cylinder_maximum]-EPSILON:vector 0 1 0
     (1>dist)∧⍵[2]≤⍺[cylinder_minimum]+EPSILON:vector 0 ¯1 0
     y←(+/⍵[1 3]*2)*0.5
     ⍵[2]>0:vector(⍵[1])(-y)(⍵[3])
     vector(⍵[1])y(⍵[3])
 }

 cross←{
        ⍝ vector  cross  vector → vector
     a←(⍺[2]×⍵[3])-⍺[3]×⍵[2]
     b←(⍺[3]×⍵[1])-⍺[1]×⍵[3]
     c←(⍺[1]×⍵[2])-⍺[2]×⍵[1]
     a,b,c,0
 }

∇ Z←cube
 Z←shape_cube identity4 identity4 material
∇

 cube_intersect←{
       ⍝ cube  cube_intersect  ray → intersection intersection
     ori←⊃⍵[1]
     dir←⊃⍵[2]
     xm←check_axis ori[1],dir[1]
     ym←check_axis ori[2],dir[2]
     zm←check_axis ori[3],dir[3]
     tmin←⌈/xm[1],ym[1],zm[1]
     tmax←⌊/xm[2],ym[2],zm[2]
     tmin>tmax:⍬
     (⍺ tmin)(⍺ tmax)
 }

 cube_normal_at←{
       ⍝ cube  cube_normal_at  point → vector
     maxc←⌈/|⍵[1 2 3]
     maxc=|⍵[1]:⍵[1]0 0 0 ⍝ vector ⍵[1] 0 0
     maxc=|⍵[2]:0(⍵[2])0 0 ⍝ vector 0 ⍵[2] 0
     0 0(⍵[3])0             ⍝ vector 0 0 ⍵[3]
 }

∇ Z←cylinder
 Z←shape_cylinder identity4 identity4 material(¯1×INFINITY)INFINITY FALSE
∇

∇ Z←CYL cylinder_intersect R;a;b;c;disc;t0;t1;y0;y1;t
       ⍝ cylinder  cylinder_intersect  ray → ⍬ or intersection intersection
 Z←⍬
       ⍝ a← ((1⌷⊃R[ray_direction])*2)+(3⌷⊃R[ray_direction])*2
 a←((ray_direction 1⊃R)*2)+(ray_direction 3⊃R)*2
 :If EPSILON<a
         ⍝ b← (2×(1⌷⊃R[ray_origin])×(1⌷⊃R[ray_direction]))+2×(3⌷⊃R[ray_origin])×(3⌷⊃R[ray_direction])
         ⍝ c← ¯1+((1⌷⊃R[ray_origin])*2)+(3⌷⊃R[ray_origin])*2
     b←(2×(ray_origin 1⊃R)×(ray_direction 1⊃R))+2×(ray_origin 3⊃R)×(ray_direction 3⊃R)
     c←¯1+((ray_origin 1⊃R)*2)+(ray_origin 3⊃R)*2
     disc←(b*2)-4×a×c
     :If 0≤disc
         t0←((-b)-disc*0.5)÷2×a
         t1←((-b)+disc*0.5)÷2×a
         :If t0>t1
             t0 t1←t1 t0
         :EndIf
           ⍝ y0← (2⌷⊃R[ray_origin])+t0×2⌷⊃R[ray_direction]
         y0←(ray_origin 2⊃R)+t0×ray_direction 2⊃R
         :If (y0>CYL[cylinder_minimum])∧y0<CYL[cylinder_maximum]
             Z←⊂CYL intersection t0
         :EndIf
           ⍝ y1← (2⌷⊃R[ray_origin])+t1×2⌷⊃R[ray_direction]
         y1←(ray_origin 2⊃R)+t1×ray_direction 2⊃R
         :If (y1>CYL[cylinder_minimum])∧y1<CYL[cylinder_maximum]
             Z←Z,⊂CYL intersection t1
         :EndIf
     :EndIf
 :EndIf
       ⍝ Check for intersection with caps of closed cylinder
 :If CYL[cylinder_closed]∧(EPSILON<|2⌷⊃R[ray_direction])
         ⍝ t← (CYL[cylinder_minimum]-2⌷⊃R[ray_origin])÷2⌷⊃R[ray_direction]
     t←(CYL[cylinder_minimum]-ray_origin 2⊃R)÷ray_direction 2⊃R
     :If R check_cap t
         Z←Z,⊂CYL intersection t
     :EndIf
         ⍝ t← (CYL[cylinder_maximum]-2⌷⊃R[ray_origin])÷2⌷⊃R[ray_direction]
     t←(CYL[cylinder_maximum]-ray_origin 2⊃R)÷ray_direction 2⊃R
     :If R check_cap t
         Z←Z,⊂CYL intersection t
     :EndIf
 :EndIf
 :If 1=≢Z
     Z←Z,Z
 :EndIf
       ⍝ I also need to make sure the list is sorted by distance
 :If Z≢⍬
     t←2⌷¨Z
     Z←Z[⍋t]
 :EndIf
∇

 cylinder_normal_at←{
       ⍝ cylinder  cylinder_normal_at  point → vector
     dist←(⍵[1]*2)+⍵[3]*2
     (1>dist)∧⍵[2]≥⍺[cylinder_maximum]-EPSILON:vector 0 1 0
     (1>dist)∧⍵[2]≤⍺[cylinder_minimum]+EPSILON:vector 0 ¯1 0
     vector(⍵[1])0(⍵[3])
 }

∇ Z←default_world;light;s1;s2;m
 light←(point ¯10 10 ¯10)point_light 1 1 1
 s1←sphere
 m←material
 m[material_color material_diffuse material_specular]←(0.8 1 0.6)0.7 0.2
 s1[obj_material]←⊂m
 s2←sphere
 s2[obj_transform]←⊂scaling 0.5 0.5 0.5
 s2[obj_inverse]←⊂⌹scaling 0.5 0.5 0.5
 Z←world
 Z[1],←⊂⊂light
 Z[2]←⊂⊂s1  ⍝ Have to enclose twice!
 Z[2],←⊂⊂s2
∇

 dot←{⍺+.×⍵}

∇ Z←G flatten_group T;gt;objs;objs
       ⍝ group  flatten_group  transform → list_of_shapes
 Z←⍬
 objs←⊃G[group_members]
 gt←⊃G[obj_transform]
 :For obj :In objs
     :If shape_group=obj[obj_tag]
         Z,←obj flatten_group gt
     :Else
         obj[obj_transform]←⊂T+.×gt+.×⊃obj[obj_transform]
         obj[obj_inverse]←⊂⌹⊃obj[obj_transform]
         Z,←⊂obj
     :EndIf
 :EndFor
∇

∇ Z←glass
 Z←(1 1 1)0.1 0.9 0.9 200 0 1.5 1
∇

∇ Z←glass_sphere
 Z←shape_sphere identity4 identity4 glass
∇

 gradient_pattern←{pat_gradient identity4 identity4 ⍺ ⍵}

∇ Z←group
 Z←shape_group identity4 identity4 ⍬ ⍬
∇

∇ Z←G group_intersect R;obj
       ⍝ group  group_intersect  ray → ⍬ or intersection_list
 Z←⍬
 :If ⍬≢⊃G[group_members]
     :For obj :In ⊃G[group_members]
         Z,←obj intersect R
     :EndFor
     :If ⍬≢Z
         Z←Z[⍋2⌷¨Z]
     :EndIf
 :EndIf
∇

 hit←{
       ⍝ hit  intersection_list → ⍬ or intersection
     ⍬≡⍵:⍬                ⍝ No list, no hit
     l←0≤hit_distance⌷¨⍵  ⍝ Positive distances
     0=∨/l:⍬              ⍝ Return null if none
     ⊃l/⍵                 ⍝ Return first from positives
 }

 identity←{⍵ ⍵⍴1,⍵⍴0}

∇ Z←identity4
 Z←identity 4
∇

 intersect←{
        ⍝ object  intersect  ray → ⍬ or intersection list
     t←⍺[obj_tag]
        ⍝ m←⊃⍺[obj_transform]
        ⍝ local_ray← (⌹m) transform ⍵
     local_ray←(⊃⍺[obj_inverse])transform ⍵
     shape_test=t:local_ray
     shape_sphere=t:⍺ sphere_intersect local_ray
     shape_plane=t:⍺ plane_intersect local_ray
     shape_cube=t:⍺ cube_intersect local_ray
     shape_cylinder=t:⍺ cylinder_intersect local_ray
     shape_cone=t:⍺ cone_intersect local_ray
     ⍬
 }

 intersect_world←{
       ⍝ world  intersect_world  ray → ⍬ or sorted intersection list
     ilist←((⍴2⊃⍺)⍴⊂⍵)intersect⍨¨2⊃⍺  ⍝ List of intersection pairs and nulls
     ilist←(~ilist∊⊂⍬)/ilist          ⍝ Remove nulls
     0=≢ilist:⍬                      ⍝ Return null if no intersections at all
     ilist←(⊃¨1↑¨ilist),⊃¨1↓¨ilist    ⍝ Remove intersections from pairs
     ∪ilist[⍋hit_distance⊃¨ilist]     ⍝ Sort by distance
 }

 intersection←{⍺⍵}

 intersections←{⍵[⍋hit_distance⊃¨⍵]}

 is_shadowed←{
        ⍝ world  is_shadowed  point → Boolean
     l←⊃⊃⍺[1]
     v←(⊃l[light_point])-⍵
     dist←magnitude v
     dir←normalize v
     r←⍵ ray dir
     inter←⍺ intersect_world r
     h←hit inter
     0=≢h:0
     h[hit_distance]<dist
 }

∇ Z←lighting Args;matl;point;eyev;normalv;insh;obj;ec;lv;am;ldn;di;f;sp;rv;rde
 (matl light point eyev normalv insh obj)←Args
 :If 3=≢⊃matl[material_color]
     clr←⊃matl[material_color]
 :Else
         ⍝ None of the earlier test cases have materials with patterns
     clr←(⊃matl[material_color])pattern_at_shape obj point
 :EndIf
 ec←clr×⊃light[light_color]      ⍝ Effective color
 lv←normalize(⊃light[light_point])-point
 am←ec×matl[material_ambient]
 ldn←lv dot normalv
 :If insh∨ldn<0   ⍝ A little bit quicker checking insh than zeroing above
     di←0 0 0
     sp←0 0 0
 :Else
     di←ec×matl[material_diffuse]×ldn
     rv←(-lv)reflect normalv
     rde←(rv dot eyev)
     :If rde≤0
         sp←0 0 0
     :Else
         f←rde*matl[material_shininess]
         sp←matl[material_specular]×f×⊃light[light_color]
     :EndIf
 :EndIf
 Z←am+di+sp
∇

 magnitude←{(+/⍵*2)*0.5}

∇ Z←material
 Z←(1 1 1)0.1 0.9 0.9 200 0 1 0
∇

 normal_at←{
        ⍝ shape normal_at point → vector
     fixup←{
          ⍝ wn← (⍉(⌹⊃⍺[obj_transform])) +.× ⍵
         wn←(⍉⊃⍺[obj_inverse])+.×⍵
         wn[4]←0
         normalize wn
     }
        ⍝ lp← ⍵⌹⊃⍺[obj_transform]   Doesn't work!?
        ⍝ lp← (⌹⊃⍺[obj_transform]) +.× ⍵
     lp←(⊃⍺[obj_inverse])+.×⍵
     t←⍺[obj_tag]
     shape_test=t:⍺ fixup vector lp[1 2 3]  ⍝ Here, or at end?
     shape_sphere=t:⍺ fixup ⍺ sphere_normal_at lp
        ⍝ Is this correct? plane_normal_at is a constant!
     shape_plane=t:⍺ fixup ⍺ plane_normal_at lp
     shape_cube=t:⍺ fixup ⍺ cube_normal_at lp
     shape_cylinder=t:⍺ fixup ⍺ cylinder_normal_at lp
     shape_cone=t:⍺ fixup ⍺ cone_normal_at lp
     shape_triangle=t:⍺ triangle_normal_at lp
     shape_smtriangle=t:⍺ smtriangle_normal_at lp
     0 0 0 0
 }

 normalize←{⍵÷(+/(⍵*2))*0.5}

 pattern_at←{
       ⍝ pattern  pattern_at  point → color
     tag←pattern_type⊃⍺
     c1←pattern_color1⊃⍺
     c2←pattern_color2⊃⍺
       ⍝ Pattern used during testing
     tag=pat_test:3↑⍵
       ⍝ Stripe pattern
     (tag=pat_stripe)∧0=⌊2|⍵[1]:c1
     (tag=pat_stripe)∧0≠⌊2|⍵[1]:c2
       ⍝ Gradient pattern
     tag=pat_gradient:c1+(c2-c1)×⍵[1]-⌊⍵[1]
       ⍝ Ring pattern
     (tag=pat_ring)∧0=⌊2|(+/⍵[1 3]×⍵[1 3])*0.5:c1
     (tag=pat_ring)∧0≠⌊2|(+/⍵[1 3]×⍵[1 3])*0.5:c2
       ⍝ Checker pattern
     (tag=pat_checker)∧0=2|+/⌊3↑⍵:c1
     (tag=pat_checker)∧0≠2|+/⌊3↑⍵:c2
 }

 pattern_at_shape←{
       ⍝ pattern  pattern_at_shape  object point → color
     (obj wpoint)←⍵
       ⍝ ⍺ pattern_at (⌹⊃⍺[pattern_transform]) +.× (⌹⊃obj[obj_transform]) +.× wpoint
     ⍺ pattern_at(⊃⍺[pattern_inverse])+.×(⊃obj[obj_inverse])+.×wpoint
 }

∇ Z←plane
 Z←shape_plane identity4 identity4 material
∇

 plane_intersect←{
        ⍝ plane plane_intersect ray → ⍬ or intersection_list
        ⍝ Must return a list of intersections
     o←⊃⍵[ray_origin]         ⍝ Ray origin
     d←⊃⍵[ray_direction]      ⍝ Ray direction
     EPSILON>|d[2]:⍬          ⍝ No intersection
     t←-(o[2])÷d[2]           ⍝ Distance
        ⍝ Return two instead of one for compatibility with sphere et al
     (⍺ t)(⍺ t)               ⍝ Intersection
 }

 plane_normal_at←{0 1 0 0}

 point←{⍵,1}

 point_light←{⍺⍵}

 position←{(⊃⍺[ray_origin])+⍵×⊃⍺[ray_direction]}

 prepare_computations←{
     ⍝ intersection  prepare_computations  ray → hit
     Z←⍺,0,0,0,0,0,0,0,0,0
        ⍝ Z[hit_point]←   ⊂ray position Z[hit_distance]
     Z[hit_point]←⊂⍵ position Z[hit_distance]
     Z[hit_eyev]←-⍵[ray_direction]
     Z[hit_normalv]←⊂(⊃Z[hit_object])normal_at⊃Z[hit_point]
        ⍝ :If 0≥ (⊃Z[hit_normalv]) dot ⊃Z[hit_eyev]
        ⍝    Z[hit_inside]← 1
        ⍝    Z[hit_normalv]← -Z[hit_normalv]
        ⍝ :Else
        ⍝    Z[hit_inside]← 0
        ⍝ :EndIf
     Z[hit_inside]←0≥(⊃Z[hit_normalv])dot⊃Z[hit_eyev]
        ⍝ Z[hit_normalv]← Z[hit_normalv]×(1 ¯1)[1+hit_inside⊃Z]
     Z[hit_normalv]×←(1 ¯1)[1+hit_inside⊃Z]
        ⍝ Note the arithmetic with enclosed vectors!
     Z[hit_overpt]←Z[hit_point]+Z[hit_normalv]×EPSILON ⍝ Added for acne
     Z[hit_underpt]←Z[hit_point]-Z[hit_normalv]×EPSILON ⍝ Added for acne
     Z[hit_reflectv]←⍵[ray_direction]reflect Z[hit_normalv]
     Z
 }

 ray←{⍺⍵}

 ray_for_pixel←{
        ⍝ camera ray_for_pixel x y → ray
     (px py)←⍵
     xoffset←⍺[camera_psize]×px+0.5
     yoffset←⍺[camera_psize]×py+0.5
     world_x←⍺[camera_halfw]-xoffset
     world_y←⍺[camera_halfh]-yoffset
        ⍝ This is actually slightly slower than the above!
        ⍝ world_x← ⍺[camera_halfw]-⍺[camera_psize]×px+0.5
        ⍝ world_y← ⍺[camera_halfh]-⍺[camera_psize]×py+0.5
        ⍝ it←      ⌹⊃⍺[camera_transform]
     it←⊃⍺[camera_inverse]
     pixel←it+.×point world_x world_y ¯1
     origin←it+.×point 0 0 0
     directn←normalize pixel-origin
     origin ray directn
 }

 reflect←{⍺-⍵×2×⍺ dot ⍵}

 reflected_color←{
        ⍝ world  reflected_color  comps remaining → color
     ~EVAL_REFLECTION:0 0 0
        ⍝ Limit recursion. Set RECURSE before calling
     (comps remaining)←⍵
     0≥remaining:0 0 0   ⍝ black if too deep
        ⍝
     o←⊃comps[hit_object]
     m←⊃o[obj_material]
     0=m[material_reflective]:0 0 0
     rray←(⊃comps[hit_overpt])ray⊃comps[hit_reflectv]
     c←⍺ color_at rray(remaining-1)
     c×m[material_reflective]
 }

 refracted_color←{
       ⍝ world  refracted_color  comps → color
     ~EVAL_REFRACTION:0 0 0
       ⍝ Fixes #5 but breaks #8
       ⍝ Infinite loop: refracted_color, color_at, shade_hit
     (comps remaining)←⍵
     0≥remaining:0 0 0  ⍝ Added for Test#5
       ⍝ Black if object is opaque
     0=hit_object obj_material material_transparency⊃comps:0 0 0
     
     n_ratio←(hit_n1⊃comps)÷hit_n2⊃comps
     cos_i←(hit_eyev⊃comps)dot hit_normalv⊃comps
     sin2_t←(1-cos_i*2)×n_ratio*2
       ⍝
     1<sin2_t:0 0 0
       ⍝
     cos_t←(1-sin2_t)*0.5
     dir←((hit_normalv⊃comps)×((n_ratio×cos_i)-cos_t))-(hit_eyev⊃comps)×n_ratio
     rray←(hit_underpt⊃comps)ray dir
     color←⍺ color_at rray(remaining-1)
     (hit_object obj_material material_transparency⊃comps)×color
 }

∇ Z←W render C;x;y;r;c;row
        ⍝ world  render  camera → canvas
        ⍝ Z← canvas C[camera_hsize], C[camera_vsize]
 Z←C[camera_vsize]⍴0
        ⍝ I changed from ⍳N to ¯1+⍳N and it worked
 :For y :In ¯1+⍳C[camera_vsize]
           ⍝ row← (y+1)⊃Z
     row←C[camera_hsize]⍴⊂0 0 0
     :For x :In ¯1+⍳C[camera_hsize]
              ⍝ When this was C ray_for_pixel x-1,y-1 data was skewed
              ⍝ I guess it should have been (x-1),y-1 eh?
         r←C ray_for_pixel x y
         c←W color_at r MAX_RECURSION
              ⍝ x=columns, y=rows. Small values to zero.
         row[x+1]←⊂{⍵<EPSILON:0 ⋄ ⍵}¨c
     :EndFor
     Z[y+1]←⊂row
 :EndFor
∇

 ring_pattern←{pat_ring identity4 identity4 ⍺ ⍵}

 rotation_x←{
        ⍝ rotation_x  angle_in_radians → transform_matrix
     idn←identity4
     idn[(2 2)(2 3)(3 2)(3 3)]←(2○⍵)(-(1○⍵))(1○⍵)(2○⍵)
     idn
 }

 rotation_y←{
        ⍝ rotation_x  angle_in_radians → transform_matrix
     idn←identity4
     idn[(1 1)(1 3)(3 1)(3 3)]←(2○⍵)(1○⍵)(-(1○⍵))(2○⍵)
     idn
 }

 rotation_z←{
        ⍝ rotation_x  angle_in_radians → transform_matrix
     idn←identity4
     idn[(1 1)(1 2)(2 1)(2 2)]←(2○⍵)(-(1○⍵))(1○⍵)(2○⍵)
     idn
 }

 savePPM←{
        ⍝ filename  savePPM  output_data
     (s,((1↑⍴s←⍕⍵),1)⍴⎕UCS 10)PutText ⍺
 }

 scaling←{
        ⍝ scaling  x y z → transform_matrix
     idn←identity4
     idn[(1 1)(2 2)(3 3)]←⍵
     idn
 }

∇ Z←schlick COMPS;cos;n;sin2_t;cos_t;r0
       ⍝ schlick  comps (updated by compute_n1n2)
 cos←(⊃COMPS[hit_eyev])dot⊃COMPS[hit_normalv]
 :If COMPS[hit_n1]>COMPS[hit_n2]
     n←COMPS[hit_n1]÷COMPS[hit_n2]
     sin2_t←(1-cos*2)×n*2
     :If sin2_t>1
         Z←1
         :Return
     :EndIf
     cos←(1-sin2_t)*0.5
 :EndIf
 r0←((COMPS[hit_n1]-COMPS[hit_n2])÷(COMPS[hit_n1]+COMPS[hit_n2]))*2
 Z←r0+(1-r0)×(1-cos)*5
∇

 shade_hit←{
     ⍝ world  shade_hit  comps remaining → color
     (comps remaining)←⍵
     wlight←⊃⊃⍺[1]
     obj←⊃comps[hit_object]
     mtrl←⊃obj[obj_material]
     insh←⍺ is_shadowed⊃comps[hit_overpt]
     surface←lighting mtrl wlight(⊃comps[hit_overpt])(⊃comps[hit_eyev])(⊃comps[hit_normalv])insh obj
     reflected←⍺ reflected_color ⍵
     refracted←⍺ refracted_color ⍵
     flag←∧/0<mtrl[material_reflective material_transparency]
     reflectance←schlick comps
     1=flag:surface+(refracted×1-reflectance)+reflected×reflectance
     surface+reflected+refracted
 }

 shearing←{
        ⍝ shearing  xy xz yx yz zx zy → transform_matrix
     idn←identity4
     idn[(1 2)(1 3)(2 1)(2 3)(3 1)(3 2)]←⍵
     idn
 }

∇ Z←sphere
 Z←shape_sphere identity4 identity4 material
∇

 sphere_intersect←{
       ⍝ sphere  intersect  ray → ⍬ or intersection_list
     s2r←(⊃⍵[ray_origin])-0 0 0 1
     a←(⊃⍵[ray_direction])dot⊃⍵[ray_direction]
     b←2×(⊃⍵[ray_direction])dot s2r
     c←¯1+s2r dot s2r
     d←(b×b)-4×a×c
     d<0:⍬
     t1←((-b)-d*0.5)÷2×a  ⍝ Clean this up!!!
     t2←((-b)+d*0.5)÷2×a
     (⍺ t1)(⍺ t2)
 }

 sphere_normal_at←{
       ⍝ ⍺=sphere  normal_at  ⍵=point → vector
     on←⍵-0 0 0 1         ⍝ Is this necessary? Yes, creates vector
       ⍝ wn← (⍉⌹⊃⍺[obj_transform]) +.× on
     wn←(⍉⊃⍺[obj_inverse])+.×on
     wn[4]←0                ⍝ Make world_normal a vector
     normalize wn
 }

 stripe_pattern←{pat_stripe identity4 identity4 ⍺ ⍵}

∇ Z←test_pattern
 Z←pat_test identity4 identity4(0 0 0)(1 1 1)
∇

∇ Z←test_shape
 Z←shape_test identity4 identity4 material
∇

 transform←{(⍺+.×⊃⍵[ray_origin])(⍺+.×⊃⍵[ray_direction])}

 translation←{
        ⍝ translation  x y z → transform_matrix
     idn←identity4
     idn[(1 4)(2 4)(3 4)]←⍵
     idn
 }

 triangle←{
       ⍝ triangle  p1 p2 p3 → shape_triangle identity4 material points edges normalv
     edges←(⍵[2]-⍵[1]),(⍵[3]-⍵[1])
     normv←normalize(⊃edges[2])cross⊃edges[1]
     shape_triangle identity4 identity4 material(⍵)edges normv
 }

 vector←{⍵,0}

 view_transform←{
        ⍝ view_transform from to up → transform_matrix
     (from to up)←⍵
     forward←normalize to-from
     left←forward cross normalize up
     true_up←left cross forward
     orientation←left[1],left[2],left[3],0,true_up[1],true_up[2],true_up[3],0
     orientation,←(-forward[1 2 3]),0,0,0,0,1
     orientation←4 4⍴orientation
     orientation+.×translation-from[1 2 3]
 }

∇ Z←world
 Z←⍬ ⍬
∇

:EndNamespace 
