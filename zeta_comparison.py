from manimlib import *
import mpmath

class ZetaComparison(Scene):
    def construct(self):
        # 1. Setup the two coordinate systems
        # Left: Input Plane (s-plane), Right: Output Plane (zeta-plane)
        s_plane = ComplexPlane(
            x_range=[0, 1, 0.5],
            y_range=[0, 50, 10],
            width=5,
            height=6
        )
        s_plane.add_coordinate_labels()

        z_plane = ComplexPlane(
            x_range=[-3, 3, 1],
            y_range=[-3, 3, 1],
            width=5,
            height=6
        )
        z_plane.add_coordinate_labels()

        group = VGroup(s_plane, z_plane).arrange(RIGHT, buff=1.5)
        self.add(group)

        # Labels for the planes
        s_label = Tex("s = 0.5 + it").next_to(s_plane, UP)
        z_label = Tex(r"\zeta(s)").next_to(z_plane, UP)
        self.add(s_label, z_label)

        # 2. The Critical Line (Input space)
        # Defined as Re(s) = 0.5
        critical_line = Line(
            s_plane.n2p(0.5),
            s_plane.n2p(0.5 + 50j),
            color=BLUE_C,
            stroke_width=2
        )
        self.add(critical_line)

        # 3. Zeta function calculation wrapper
        def zeta_func(t):
            # Complex zeta calculation using mpmath
            z = mpmath.zeta(complex(0.5, t))
            return z_plane.n2p(complex(z))

        # 4. The Zeta Spiral (Output space)
        # Created with a fine step for 4K smoothness
        spiral = ParametricCurve(
            zeta_func,
            t_range=[0, 50, 0.05],
            color=YELLOW,
            stroke_width=2
        )

        # 5. Interactive Trackers and Updaters
        t_tracker = ValueTracker(0)

        # Moving Dot on the Input Plane (Vertical motion)
        input_dot = Dot(color=WHITE, radius=0.08).add_updater(
            lambda m: m.move_to(s_plane.n2p(complex(0.5, t_tracker.get_value())))
        )

        # Moving Dot on the Output Plane (Spiral motion)
        output_dot = Dot(color=WHITE, radius=0.08).add_updater(
            lambda m: m.move_to(zeta_func(t_tracker.get_value()))
        )

        # Numerical t-counter
        t_text = DecimalNumber(0, num_decimal_places=2).scale(0.8)
        t_text.add_updater(lambda m: m.set_value(t_tracker.get_value()))
        t_label = VGroup(Tex("t = ", font_size=36), t_text).arrange(RIGHT)
        t_label.next_to(s_label, RIGHT, buff=0.5)

        self.add(input_dot, output_dot, t_label)

        # 6. Logic to "Drop" Red Dots at Zeros
        # We fetch the first 9 zeros and add red markers that appear only when reached
        for i in range(1, 10):
            t_zero = float(mpmath.zetazero(i).imag)

            # Input plane markers (Addresses)
            dot_in = always_redraw(lambda t=t_zero:
                Dot(s_plane.n2p(complex(0.5, t)), color=RED, radius=0.06)
                if t_tracker.get_value() >= t else VMobject()
            )

            # Output plane markers (Origin bullseye)
            dot_out = always_redraw(lambda t=t_zero:
                Dot(z_plane.n2p(0), color=RED, radius=0.06)
                if t_tracker.get_value() >= t else VMobject()
            )

            self.add(dot_in, dot_out)

        # 7. Execute Animation
        # We use ShowCreation for the spiral and animate the tracker simultaneously
        self.play(Write(s_label), Write(z_label))
        self.play(
            ShowCreation(spiral),
            t_tracker.animate.set_value(50),
            run_time=25,
            rate_func=linear
        )
        self.wait(3)
