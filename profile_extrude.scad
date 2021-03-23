/* ##  #   # # ###  ## ### ### ### ###    ## ### ### ###
 * # # #   # # #   #    #  # # # # #     #   # # #    #
 * ##  #   # # ##   #   #  # # # # ##     #  # # ##   #
 * # # #   # # #     #  #  # # # # #       # # # #    #
 * ##  ### ### ### ##   #  ### # # ###   ##  ### #    #
 *
 * Graphical toolkit module - profile_extrude() - version 1.0
 *
 * Functionally equivalent to
 * ` rotate_extrude(angle = 360)
 * `   polygon(points = profile_points)
 * except instead of rolling around a circle, the profile
 * rolls around another polygon defined by shape_points
 *
 * The difficulty I experienced in this project came from:
 *   - Using polyhedron() for the first time
 *   - Forgetting to debug the shape with Thrown Together mode
 *   - Adding support for a concave profile_points
 *   - Creating an efficient design with as few faces as possible
 *
 * Usage: profile_extrude(profile_points, shape_points, show_points)
 *     profile_points  The desired profile of the new shape
 *     shape_points    The polygon to extrude to the profile
 *     show_points     true/false - Show the computed points
 */

// Test model, showcasing support for concave profiles
profile_extrude(
    profile_points = [
        [1, 0], [1, 5], [2, 5], [2, 3],
        [3, 3], [3, 6], [1, 6], [1, 10]
    ],
    shape_points = [
        [-1, -1], [-1, 1], [1, 1], [1, -1]
    ],
    show_points = true
);

module profile_extrude(profile_points, shape_points, show_points = true) {

    shape_len = len(shape_points);

    // Compute all points required for polyhedron
    new_points = [
        for (p = profile_points)
            for (q = shape_points)
                [q.x * p.x, q.y * p.x, p.y]
    ];

    // If requested, mark points with small cubes
    if (show_points)
        for (p = new_points)
            translate(p)
                cube(0.1, center = true);

    // Create the actual polyhedron
    polyhedron(

        // Pass in the points we've already computed
        points = new_points,

        faces = [

            // End cap for bottom of extruded shape
            [for (i = [shape_len - 1 : -1 : 0]) i],

            // End cap for top of extruded shape
            [for (i = [0 : 1 : shape_len - 1]) len(new_points) - 4 + i],

            // Faces along the profile of shape
            for (j = [0 : 1 : len(profile_points) - 1])
                for (i = [0 : 1 : shape_len - 1])
                    [
                        j * 4 +              i,
                        j * 4 +             (i + 1) % shape_len,
                        j * 4 + shape_len + (i + 1) % shape_len,
                        j * 4 + shape_len +  i
                    ]
            
        ]

    );

}