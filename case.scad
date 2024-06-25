// clang-format off
include <lib.scad>;
// clang-format on

/* [Gaps between board and case] */
left_case_gap = 0.5;
right_case_gap = 0.5;
front_case_gap = 0.5;
back_case_gap = 0.5;
bottom_case_gap = 2.5;
top_case_gap = 6.5;

/* [Case wall thickness] */
left_case_wall_thickness = 2.2;
right_case_wall_thickness = 2.2;
front_case_wall_thickness = 2.2;
back_case_wall_thickness = 2.2;
bottom_case_wall_thickness = 2.2;
top_case_wall_thickness = 2.2;

/* [Access slots] */
left_pins_accessible = true;

right_pins_accessible = true;

usb_port_accessible = true;

eth_port_accessible = true;

power_port_accessible = true;

recovery_button_accessible = true;
recovery_button_lever_enabled = true;

rst_button_accessible = true;
rst_button_lever_enabled = true;

arch_switch_accessible = false;

sd_card_present = true;
sd_card_accessible = true;

leds_accessible = true;

left_mipi_csi_accessible = false;

right_mipi_csi_accessible = false;

wifi_antenna_accessible = false;

/* [Heatsink heights] */
wifi_chip_heatsink_height = 0;
cpu_chip_heatsink_height = 0;

/* [Grids] */
round_grid_borders = true;
top_face_grid_angle = 0;
bottom_face_grid_angle = 0;
left_face_grid_angle = 0;
right_face_grid_angle = 0;
top_face_grid_enabled = true;
bottom_face_grid_enabled = true;
left_face_grid_enabled = true;
right_face_grid_enabled = true;

/* [Snap joints] */
snap_joints_per_side = 6;
snap_joint_radius = 1; // [0.5:0.1:1.5]

/* [Misc case parameters] */
case_fillet_radius = 1.5;
case_slot_gap = 0.3;

module customizer_limit() {}

// Board dimensions

board_size = [ 43.5, 43.5, 1.6 ];
board_pos = [ 0, 0, -board_size.z ];

// Case dimensions

left_case_offset = left_case_gap + left_case_wall_thickness;
right_case_offset = right_case_gap + right_case_wall_thickness;
top_case_offset = top_case_gap + top_case_wall_thickness;
bottom_case_offset = bottom_case_gap + bottom_case_wall_thickness;
front_case_offset = front_case_gap + front_case_wall_thickness;
back_case_offset = back_case_gap + back_case_wall_thickness;

case_offsets = [
  left_case_offset, right_case_offset, front_case_offset, back_case_offset,
  bottom_case_offset,
  top_case_offset
];

case_pos = board_pos - [ left_case_offset, front_case_offset, bottom_case_offset ];
case_size = board_size + [
  left_case_offset + right_case_offset, front_case_offset + back_case_offset,
  bottom_case_offset +
  top_case_offset
];

case_hollow_pos = board_pos - [ left_case_gap, front_case_gap, bottom_case_gap ];
case_hollow_size = board_size + [
  left_case_gap + right_case_gap, front_case_gap + back_case_gap, bottom_case_gap +
  top_case_gap
];

button_slot_gap = case_slot_gap * 3;

// Board plate

screw_slot_radius = 1.2;
screw_slot_height = board_size.z;
left_front_screw_slot_pos = board_pos + [ 2.6, 2.6, 0 ];
right_front_screw_slot_pos = board_pos + [ board_size.x - 2.6, 2.6, 0 ];
right_back_screw_slot_pos = board_pos + [ board_size.x - 2.6, board_size.y - 2.6, 0 ];
left_back_screw_slot_pos = board_pos + [ 2.6, board_size.y - 2.6, 0 ];
screw_slot_pos = [
  left_front_screw_slot_pos,
  right_front_screw_slot_pos,
  right_back_screw_slot_pos,
  left_back_screw_slot_pos,
];

module board_plate(offset = [ 0, 0, 0 ]) {
  board_rounding = 1.5;

  difference() {
    translate(board_pos - offset) linear_extrude(board_size.z + offset.z * 2)
      offset(board_rounding) offset(-board_rounding)
        square([ board_size.x + offset.x * 2, board_size.y + offset.y * 2 ]);

    if (offset.x == 0 && offset.y == 0 && offset.z == 0)
      for (i = [0:len(screw_slot_pos) - 1])
        translate(screw_slot_pos[i] - [ 0, 0, tiny ])
          cylinder(h = screw_slot_height + tiny * 2, r = screw_slot_radius);
  }
}

// Arch switch

arch_switch_size = [ 6.8, 4.3, 1.3 ];
arch_switch_pos = board_pos + [ 9.7, -1.4, -arch_switch_size.z ];

module arch_switch(slot_gap) {
  translate(arch_switch_pos) offset_cube(arch_switch_size, slot_gap);
}

module arch_switch_access() {
  finger_access = 2.5;

  arch_switch_slot_size = [
    arch_switch_size.x, min(front_case_offset + finger_access, 10),
    min(10, bottom_case_offset)
  ];

  arch_switch_slot_pos = arch_switch_pos + [
    0, finger_access - arch_switch_slot_size.y,
    arch_switch_size.z - arch_switch_slot_size.z
  ];

  translate(arch_switch_slot_pos) offset_cube(arch_switch_slot_size, case_slot_gap);
}

// CPU chip

cpu_chip_size = [ 10, 10, 1 + cpu_chip_heatsink_height ];
cpu_chip_pos = board_pos + [ 20.4, 11, board_size.z ];

module cpu_chip(slot_gap) {
  translate(cpu_chip_pos) offset_cube(cpu_chip_size, slot_gap);
}

// ETH port

eth_port_size = [ 16, 21.1, 13.4 ];
eth_port_pos = board_pos + [ 18, 26.6, board_size.z ];
eth_port_should_be_hidden =
  !eth_port_accessible && (eth_port_pos.y + eth_port_size.y + case_slot_gap) <
                            (case_hollow_pos.y + case_hollow_size.y);

module eth_port(slot_gap) {
  translate(eth_port_pos) offset_cube(eth_port_size, slot_gap);
}

module eth_port_access() {
  case_max_y = board_size.y + back_case_offset;

  eth_port_slot_pos = eth_port_pos + [ 0, eth_port_size.y, 0 ];

  eth_port_slot_size =
    [ eth_port_size.x, max(0, case_max_y - eth_port_slot_pos.y), eth_port_size.z ];

  translate(eth_port_slot_pos) offset_cube(eth_port_slot_size, case_slot_gap);
}

// Leds

leds_size = [ 2.5, 2.5, 0.3 ];
leds_pos = board_pos + [ 23.2, 0, board_size.z ];

module leds_access() {
  leds_slot_center = leds_pos + [ leds_size.x, leds_size.y, 0 ] / 2;
  leds_slot_height = top_case_offset;
  leds_slot_radius = max(leds_size.x, leds_size.y) / 2;

  translate(leds_slot_center)
    offset_cylinder(h = leds_slot_height, r = leds_slot_radius, offset = case_slot_gap);
}

// Left MIPI CSI

left_mipi_csi_size = [ 2.4, 13.6, 4.6 ];
left_mipi_csi_pos = board_pos + [ 7, 15.9, board_size.z ];

module left_mipi_csi(slot_gap) {
  translate(left_mipi_csi_pos) offset_cube(left_mipi_csi_size, slot_gap);
}

module left_mipi_csi_access() {
  left_mipi_csi_slot_size = [ 1, left_mipi_csi_size.y - 3, top_case_offset ];
  left_mipi_csi_slot_pos = left_mipi_csi_pos + [ 0.5, 1.5, 0 ];

  translate(left_mipi_csi_slot_pos) offset_cube(left_mipi_csi_slot_size, case_slot_gap);
}

// Left pins

left_pins_size = [ 5, 33.5, 11.7 ];
left_pins_pos = board_pos + [ 0, 5, board_size.z - 3 ];

case_top_face_is_above_left_pins = top_case_offset >
                                   (left_pins_pos.z + left_pins_size.z);

module left_pins(slot_gap) {
  translate(left_pins_pos) offset_cube(left_pins_size, slot_gap);
}

module left_pins_access() {
  left_pins_slot_size =
    [ left_case_offset + left_pins_size.x, left_pins_size.y, top_case_offset ];

  left_pins_slot_pos = [ left_pins_pos.x - left_case_offset, left_pins_pos.y, 0 ];

  if (case_top_face_is_above_left_pins)
    translate(left_pins_slot_pos) offset_cube(left_pins_slot_size, case_slot_gap);
}

// Power port

power_port_size = [ 9, 7.4, 3.2 ];
power_port_pos = board_pos + [ 13.3, -1.6, board_size.z ];

module power_port(slot_gap) {
  translate(power_port_pos) offset_cube(power_port_size, slot_gap);
}

module power_port_access() {
  power_port_slot_size = [ power_port_size.x, -front_case_offset, power_port_size.z ];

  power_connector_slot_y = power_port_pos.y - 1.5;

  power_connector_slot_size = [ 12, -front_case_offset, 5.5 ];

  power_connector_slot_pos = [
    power_port_pos.x - (power_connector_slot_size.x - power_port_size.x) / 2,
    power_connector_slot_y,
    power_port_pos.z - (power_connector_slot_size.z - power_port_size.z) / 2
  ];

  translate(power_port_pos) offset_cube(power_port_slot_size, case_slot_gap);
  translate(power_connector_slot_pos)
    offset_cube(power_connector_slot_size, case_slot_gap);
}

// Recovery button

recovery_button_size = [ 4.5, 3, 3.4 ];
recovery_button_pos = board_pos + [ 27, 0, board_size.z ];
recovery_button_knob_center =
  recovery_button_pos + [ recovery_button_size.x, 0, recovery_button_size.z ] / 2;
recovery_button_knob_length = 0.5;
recovery_button_knob_radius = 1;
recovery_button_knob_rotation = [90];

module recovery_button(slot_gap) {
  translate(recovery_button_pos) offset_cube(recovery_button_size, slot_gap);
  translate(recovery_button_knob_center) rotate(recovery_button_knob_rotation)
    offset_cylinder(h = recovery_button_knob_length, r = recovery_button_knob_radius,
                    offset = slot_gap);
}

module recovery_button_access() {
  recovery_button_knob_slot_length = front_case_offset;

  translate(recovery_button_knob_center) rotate(recovery_button_knob_rotation)
    offset_cylinder(h = recovery_button_knob_slot_length,
                    r = recovery_button_knob_radius, offset = button_slot_gap);
}

// Right MIPI CSI

right_mipi_csi_size = [ 4, 22.2, 5.5 ];
right_mipi_csi_pos = board_pos + [ 31.8, 4, board_size.z ];

module right_mipi_csi(slot_gap) {
  translate(right_mipi_csi_pos) offset_cube(right_mipi_csi_size, slot_gap);
}

module right_mipi_csi_access() {
  right_mipi_csi_slot_size = [ 1, right_mipi_csi_size.y - 5, top_case_offset ];
  right_mipi_csi_slot_pos = right_mipi_csi_pos + [ 0.5, 2.5, 0 ];

  translate(right_mipi_csi_slot_pos)
    offset_cube(right_mipi_csi_slot_size, case_slot_gap);
}

// Right pins

right_pins_size = [ 5, 33.5, 11.7 ];
right_pins_pos = board_pos + [ board_size.x - right_pins_size.x, 5, board_size.z - 3 ];

case_top_face_is_above_right_pins = top_case_offset >
                                    (right_pins_pos.z + right_pins_size.z);

module right_pins(slot_gap) {
  translate(right_pins_pos) offset_cube(right_pins_size, slot_gap);
}

module right_pins_access() {
  right_pins_slot_size =
    [ right_case_offset + right_pins_size.x, right_pins_size.y, top_case_offset ];

  right_pins_slot_pos = [ right_pins_pos.x, right_pins_pos.y, 0 ];

  if (case_top_face_is_above_right_pins)
    translate(right_pins_slot_pos) offset_cube(right_pins_slot_size, case_slot_gap);
}

// RST button

rst_button_size = [ 4.5, 3, 3.4 ];
rst_button_pos = board_pos + [ 33, 0, board_size.z ];
rst_button_knob_center =
  rst_button_pos + [ rst_button_size.x, 0, rst_button_size.z ] / 2;
rst_button_knob_length = 0.5;
rst_button_knob_radius = 1;
rst_button_knob_rotation = [90];

module rst_button(slot_gap) {
  translate(rst_button_pos) offset_cube(rst_button_size, slot_gap);
  translate(rst_button_knob_center) rotate(rst_button_knob_rotation) offset_cylinder(
    h = rst_button_knob_length, r = rst_button_knob_radius, offset = slot_gap);
}

module rst_button_access() {
  rst_button_knob_slot_length = front_case_offset;

  translate(rst_button_knob_center) rotate(rst_button_knob_rotation)
    offset_cylinder(h = rst_button_knob_slot_length, r = rst_button_knob_radius,
                    offset = button_slot_gap);
}

// SD card

sd_card_size = [ 11.4, sd_card_present ? 15.4 : 11.4, 1.3 ];
sd_card_pos = board_pos + [ 24.8, sd_card_present ? -1.9 : 2.1, -sd_card_size.z ];

module sd_card(slot_gap) { translate(sd_card_pos) offset_cube(sd_card_size, slot_gap); }

module sd_card_access() {
  finger_access = 3.5;

  sd_card_slot_size = [
    sd_card_size.x, min(front_case_offset + finger_access, 15),
    min(10, bottom_case_offset)
  ];

  sd_card_slot_pos =
    sd_card_pos +
    [ 0, finger_access - sd_card_slot_size.y, sd_card_size.z - sd_card_slot_size.z ];

  translate(sd_card_slot_pos) offset_cube(sd_card_slot_size, case_slot_gap);
}

// USB port

usb_port_size = [ 6.5, 13.8, 13.1 ];
usb_port_pos = board_pos + [ 9.2, 34, board_size.z ];
usb_port_should_be_hidden =
  !usb_port_accessible && ((usb_port_pos.y + usb_port_size.y + case_slot_gap) <
                           (case_hollow_pos.y + case_hollow_size.y));

module usb_port(slot_gap) {
  usb_port_expand_size = [ 7.1, 0.8, 14.4 ];
  usb_port_expand_pos = usb_port_pos - [
    (usb_port_expand_size.x - usb_port_size.x) / 2,
    usb_port_expand_size.y - usb_port_size.y,
    (usb_port_expand_size.z - usb_port_size.z) / 2
  ];

  translate(usb_port_pos) offset_cube(usb_port_size, slot_gap);
  translate(usb_port_expand_pos) offset_cube(usb_port_expand_size, slot_gap);
}

module usb_port_access() {
  case_max_y = board_size.y + back_case_offset;

  usb_port_slot_pos = usb_port_pos + [ 0, usb_port_size.y, 0 ];

  usb_port_slot_size =
    [ usb_port_size.x, max(0, case_max_y - usb_port_slot_pos.y), usb_port_size.z ];

  usb_connector_slot_y = usb_port_slot_pos.y + 3;

  usb_connector_slot_size = [ 8.1, max(0, case_max_y - usb_connector_slot_y), 18.2 ];

  usb_connector_slot_pos = [
    usb_port_pos.x - (usb_connector_slot_size.x - usb_port_size.x) / 2,
    usb_connector_slot_y,
    usb_port_pos.z - (usb_connector_slot_size.z - usb_port_size.z) / 2
  ];

  translate(usb_port_slot_pos) offset_cube(usb_port_slot_size, case_slot_gap);
  translate(usb_connector_slot_pos) offset_cube(usb_connector_slot_size, case_slot_gap);
}

// Wifi antenna mount

wifi_antenna_mount_radius = 1.5;
wifi_antenna_mount_height = 2.4;
wifi_antenna_mount_pos =
  board_pos +
  [ 7 + wifi_antenna_mount_radius, 0.2 + wifi_antenna_mount_radius, board_size.z ];

module wifi_antenna_mount(slot_gap) {
  translate(wifi_antenna_mount_pos) offset_cylinder(
    h = wifi_antenna_mount_height, r = wifi_antenna_mount_radius, offset = slot_gap);
}

module wifi_antenna_access() {
  wifi_antenna_slot_size = [
    wifi_antenna_mount_radius * 2, wifi_antenna_mount_pos.y - case_pos.y,
    wifi_antenna_mount_height
  ];

  wifi_antenna_slot_pos = wifi_antenna_mount_pos +
                          [ -wifi_antenna_mount_radius, -wifi_antenna_slot_size.y, 0 ];

  translate(wifi_antenna_slot_pos) offset_cube(wifi_antenna_slot_size, case_slot_gap);
}

// Wifi chip

wifi_chip_size = [ 5, 5, 0.8 + wifi_chip_heatsink_height ];
wifi_chip_pos = board_pos + [ 7.3, 8.5, board_size.z ];

module wifi_chip(slot_gap) {
  translate(wifi_chip_pos) offset_cube(wifi_chip_size, slot_gap);
}

// Board

module board(slot_gap = 0) {
  board_plate([ 0, 0, slot_gap / 2 ]);
  left_pins(slot_gap);
  right_pins(slot_gap);
  usb_port(slot_gap);
  eth_port(slot_gap);
  power_port(slot_gap);
  recovery_button(slot_gap);
  rst_button(slot_gap);
  arch_switch(slot_gap);
  sd_card(slot_gap);
  left_mipi_csi(slot_gap);
  right_mipi_csi(slot_gap);
  wifi_chip(slot_gap);
  cpu_chip(slot_gap);
  wifi_antenna_mount(slot_gap);
}

module board_slot() {
  board(case_slot_gap);

  if (left_pins_accessible)
    left_pins_access();
  if (right_pins_accessible)
    right_pins_access();
  if (usb_port_accessible)
    usb_port_access();
  if (eth_port_accessible)
    eth_port_access();
  if (power_port_accessible)
    power_port_access();
  if (recovery_button_accessible)
    recovery_button_access();
  if (rst_button_accessible)
    rst_button_access();
  if (arch_switch_accessible)
    arch_switch_access();
  if (sd_card_accessible)
    sd_card_access();
  if (leds_accessible)
    leds_access();
  if (left_mipi_csi_accessible)
    left_mipi_csi_access();
  if (right_mipi_csi_accessible)
    right_mipi_csi_access();
  if (wifi_antenna_accessible)
    wifi_antenna_access();
}

// Board stops

module board_stops(expand_top, expand_bottom, gap = 0) {
  joint_step = 4;
  board_stop_height = board_size.z + (expand_top ? top_case_gap : 0) +
                      (expand_bottom ? bottom_case_gap : 0);
  board_stop_z = -(expand_bottom ? bottom_case_gap : 0);

  function board_stop_pos(from, to) = [
    board_pos + [ from.x, from.y, board_stop_z ],
    board_pos + [ to.x, to.y, board_stop_z ]
  ];

  board_stop_radius = 0.25 + gap;
  board_stop_fillet = 0.25 + gap;
  board_stop_offset = board_stop_radius + board_stop_fillet;

  x_between_usb_and_eth_ports =
    (usb_port_pos.x + usb_port_size.x + eth_port_pos.x) / 2 - board_pos.x;

  x_between_sd_card_and_power_port =
    (power_port_pos.x + power_port_size.x + sd_card_pos.x) / 2 - board_pos.x;

  board_stops_positions = [
    board_stop_pos(from = [ joint_step, -front_case_gap ],
                   to = [ joint_step, -board_stop_offset ]),
    board_stop_pos(from = [ board_size.x - joint_step, -front_case_gap ],
                   to = [ board_size.x - joint_step, -board_stop_offset ]),
    board_stop_pos(from = [ -left_case_gap, joint_step ],
                   to = [ -board_stop_offset, joint_step ]),
    board_stop_pos(from = [ board_size.x + right_case_gap, joint_step ],
                   to = [ board_size.x + board_stop_offset, joint_step ]),
    board_stop_pos(from = [ -left_case_gap, board_size.y - joint_step ],
                   to = [ -board_stop_offset, board_size.y - joint_step ]),
    board_stop_pos(from = [ board_size.x + right_case_gap, board_size.y - joint_step ],
                   to =
                     [ board_size.x + board_stop_offset, board_size.y - joint_step ]),
    board_stop_pos(from = [ joint_step, board_size.y + back_case_gap ],
                   to = [ joint_step, board_size.y + board_stop_offset ]),
    board_stop_pos(from = [ board_size.x - joint_step, board_size.y + back_case_gap ],
                   to =
                     [ board_size.x - joint_step, board_size.y + board_stop_offset ]),
    board_stop_pos(from = [ x_between_usb_and_eth_ports, board_size.y + back_case_gap ],
                   to =
                     [ x_between_usb_and_eth_ports, board_size.y + board_stop_offset ]),
    board_stop_pos(from = [ x_between_sd_card_and_power_port, -front_case_gap ],
                   to = [ x_between_sd_card_and_power_port, -board_stop_offset ])
  ];

  for (i = [0:len(board_stops_positions) - 1])
    hull() {
      translate(board_stops_positions[i][0]) offset_cylinder(
        h = board_stop_height, r = board_stop_radius, offset = board_stop_fillet);
      translate(board_stops_positions[i][1]) offset_cylinder(
        h = board_stop_height, r = board_stop_radius, offset = board_stop_fillet);
    }
}

// Grids

module top_face_grid_slot() {
  shell = -3;
  bottom_x = left_pins_pos.x + left_pins_size.x;
  top_x = right_pins_pos.x;
  bottom_y = left_pins_pos.y - case_slot_gap + shell;
  top_y = left_pins_pos.y + left_pins_size.y + case_slot_gap - shell;
  points =
    (eth_port_pos.z + eth_port_size.z + case_slot_gap) >
        (board_pos.z + board_size.z + top_case_gap) ?
      [
        [ bottom_x, bottom_y ],
        [ bottom_x, usb_port_pos.y ],
        [ eth_port_pos.x, usb_port_pos.y ],
        [ eth_port_pos.x, eth_port_pos.y ],
        [ top_x, eth_port_pos.y ],
        [ top_x, bottom_y ],
      ] :
      [[bottom_x, bottom_y], [bottom_x, top_y], [top_x, top_y], [top_x, bottom_y]];

  translate([ 0, 0, board_pos.z + board_size.z + top_case_gap - tiny ])
    linear_extrude(top_case_wall_thickness + tiny * 2)
      grid_slot(points = points, step = [ 2.5, case_size.y ], shell = shell,
                rounding = 0.499, angle = top_face_grid_angle,
                round_grid_border = round_grid_borders) translate([ -1.5, 0 ])
        square([ 1.5, case_size.y ]);
}

module bottom_face_grid_slot() {
  shell = -3;
  bottom_x = left_pins_pos.x + left_pins_size.x;
  top_x = right_pins_pos.x;
  bottom_y = left_pins_pos.y - case_slot_gap;
  top_y = left_pins_pos.y + left_pins_size.y - shell + case_slot_gap;

  translate([ 0, 0, case_pos.z - tiny ])
    linear_extrude(bottom_case_wall_thickness + tiny * 2)
      grid_slot(points = [[bottom_x, bottom_y], [top_x, bottom_y], [top_x, top_y],
                          [bottom_x, top_y]],
                step = [ 2.5, case_size.y ], shell = shell, rounding = 0.499,
                angle = bottom_face_grid_angle, round_grid_border = round_grid_borders)
        translate([ -1, 0 ]) square([ 1, case_size.y ]);
}

module left_face_grid_slot() {
  bottom_x = left_pins_pos.y + left_pins_size.y;
  top_x = left_pins_pos.y;
  bottom_y = bottom_case_wall_thickness - bottom_case_gap - board_size.z;
  top_y = top_case_gap - top_case_wall_thickness;

  translate([ case_pos.x - tiny, 0, board_pos.z + board_size.z ]) rotate([ 90, 0, 90 ])
    linear_extrude(left_case_wall_thickness + tiny * 2)
      grid_slot(points = [[bottom_x, bottom_y], [top_x, bottom_y], [top_x, top_y],
                          [bottom_x, top_y]],
                step = [ 2.5, case_size.z ], rounding = 0.499,
                angle = left_face_grid_angle, round_grid_border = round_grid_borders)
        square([ 1, case_size.z ]);
}

module right_face_grid_slot() {
  bottom_x = right_pins_pos.y + right_pins_size.y;
  top_x = right_pins_pos.y;
  bottom_y = bottom_case_wall_thickness - bottom_case_gap - board_size.z;
  top_y = top_case_gap - top_case_wall_thickness;

  translate(
    [ case_hollow_pos.x + case_hollow_size.x - tiny, 0, board_pos.z + board_size.z ])
    rotate([ 90, 0, 90 ]) linear_extrude(right_case_wall_thickness + tiny * 2)
      grid_slot(points = [[bottom_x, bottom_y], [top_x, bottom_y], [top_x, top_y],
                          [bottom_x, top_y]],
                step = [ 2.5, case_size.z ], rounding = 0.499,
                angle = right_face_grid_angle, round_grid_border = round_grid_borders)
        square([ 1, case_size.z ]);
}

// Lever buttons

// reduces button height if case height is small
function lever_button_size(angle, width, max_height) = [
  width, max_height / cos(abs(angle) % 90) - width / 2 / tan(90 - abs(angle) % 90),
  front_case_wall_thickness + tiny * 2
];

recovery_button_slot_angle = -45;
recovery_button_slot_size = lever_button_size(
  angle = recovery_button_slot_angle, width = 4.5,
  max_height = min(
    case_pos.z + case_size.z - recovery_button_knob_center.z - case_fillet_radius, 6));
recovery_button_slot_center = [
  recovery_button_knob_center.x, case_hollow_pos.y + tiny, recovery_button_knob_center.z
];

module recovery_lever_button_slot() {
  recovery_button_slot_radius = recovery_button_knob_radius + button_slot_gap;

  translate(recovery_button_slot_center) rotate([ 90, recovery_button_slot_angle ])
    lever_button_slot(recovery_button_slot_size, recovery_button_slot_radius);
}

module recovery_lever_button() {
  recovery_button_lever_size =
    [ recovery_button_slot_size.x - case_slot_gap * 2, recovery_button_slot_size.y, 1 ];
  recovery_button_lever_reach = front_case_offset - case_slot_gap;

  translate(recovery_button_slot_center + [ 0, -front_case_wall_thickness, 0 ])
    rotate([ 90, -recovery_button_slot_angle, 180 ])
      lever_button(recovery_button_lever_size, recovery_button_knob_radius,
                   recovery_button_lever_reach);
}

rst_button_slot_angle = 45;
rst_button_slot_size = lever_button_size(
  angle = rst_button_slot_angle, width = 4.5,
  max_height =
    min(case_pos.z + case_size.z - rst_button_knob_center.z - case_fillet_radius, 6));
rst_button_slot_center =
  [ rst_button_knob_center.x, case_hollow_pos.y + tiny, rst_button_knob_center.z ];

module rst_lever_button_slot() {
  rst_button_slot_radius = rst_button_knob_radius + button_slot_gap;

  translate(rst_button_slot_center) rotate([ 90, rst_button_slot_angle ])
    lever_button_slot(rst_button_slot_size, rst_button_slot_radius);
}

module rst_lever_button() {
  rst_button_lever_size =
    [ rst_button_slot_size.x - case_slot_gap * 2, rst_button_slot_size.y, 1 ];
  rst_button_lever_reach = front_case_offset - case_slot_gap;

  translate(rst_button_slot_center + [ 0, -front_case_wall_thickness, 0 ])
    rotate([ 90, -rst_button_slot_angle, 180 ]) lever_button(
      rst_button_lever_size, rst_button_knob_radius, rst_button_lever_reach);
}

// Support column

module support_column() {
  support_column_pos =
    [ usb_port_pos.x + usb_port_size.x, usb_port_pos.y, board_pos.z + board_size.z ];

  support_column_size = [
    eth_port_pos.x - support_column_pos.x, eth_port_pos.x - support_column_pos.x,
    top_case_gap
  ];

  column_reinforcer_pos = [
    support_column_pos.x, support_column_pos.y,
    board_pos.z + board_size.z + top_case_gap / 3 * 2
  ];

  column_reinforcer_size = [
    support_column_size.x,
    case_hollow_pos.y + case_hollow_size.y - support_column_pos.y, top_case_gap / 3
  ];

  translate(support_column_pos) cube(support_column_size);
  translate(column_reinforcer_pos) cube(column_reinforcer_size);
}

// Case blueprint

module case_shape() {
  translate(case_pos) smooth_cube(case_size, fillet = case_fillet_radius);
}

module hollow_shape() {
  translate(case_hollow_pos) smooth_cube(case_hollow_size, fillet = case_fillet_radius);
}

module hollow_case_shape() {
  difference() {
    case_shape();

    hollow_shape();
  }

  children();
}

module case_blueprint(expand_board_stops_bottom = false,
                      expand_board_stops_top = false) {
  difference() {
    intersection() {
      hollow_case_shape() {
        board_stops(expand_top = expand_board_stops_top,
                    expand_bottom = expand_board_stops_bottom);
        support_column();

        children();
      }

      case_shape();
    }

    board_slot();

    if (top_face_grid_enabled)
      top_face_grid_slot();
    if (bottom_face_grid_enabled)
      bottom_face_grid_slot();
    if (!case_top_face_is_above_left_pins && left_face_grid_enabled)
      left_face_grid_slot();
    if (!case_top_face_is_above_right_pins && right_face_grid_enabled)
      right_face_grid_slot();

    if (recovery_button_accessible && recovery_button_lever_enabled)
      recovery_lever_button_slot();
    if (rst_button_accessible && rst_button_lever_enabled)
      rst_lever_button_slot();
  }

  if (recovery_button_accessible && recovery_button_lever_enabled)
    recovery_lever_button();
  if (rst_button_accessible && rst_button_lever_enabled)
    rst_lever_button();
}

// Snap case

module corner_columns() {
  top_clamp_radius = (left_pins_pos.y - board_pos.y) / 2 - case_slot_gap;
  fillet = 3;

  for (i = [0:len(screw_slot_pos) - 1])
    translate([ screw_slot_pos[i].x, screw_slot_pos[i].y, case_hollow_pos.z ])
      fillet_cylinder(h = case_hollow_size.z, r = top_clamp_radius, top_fillet = fillet,
                      bottom_fillet = fillet);
}

module case_snaps(gap) {
  x_step = case_hollow_size.x / (snap_joints_per_side + 1);
  y_step = case_hollow_size.y / (snap_joints_per_side + 1);
  z_pos = case_pos.z + case_fillet_radius * 0.3 + bottom_case_wall_thickness * 0.5;

  snap_points = concat(
    [for (i = [1:snap_joints_per_side]) each
      [[case_hollow_pos.x + x_step * i,
        case_hollow_pos.y + case_hollow_size.y - gap - tiny, [-90]],
       [case_hollow_pos.x + x_step * i, case_hollow_pos.y + gap + tiny, [90]],
       [case_hollow_pos.x + gap + tiny, case_hollow_pos.y + y_step * i, [0, -90]],
       [case_hollow_pos.x + case_hollow_size.x - gap - tiny,
        case_hollow_pos.y + y_step * i, [0, 90]]]],
    usb_port_should_be_hidden ?
      [] :
      [[usb_port_pos.x,
        case_hollow_pos.y + case_hollow_size.y + back_case_wall_thickness / 2,
        [0, -90]]],
    eth_port_should_be_hidden ?
      [] :
      [[eth_port_pos.x + eth_port_size.x,
        case_hollow_pos.y + case_hollow_size.y + back_case_wall_thickness / 2,
        [0, 90]]]);

  for (i = [0:len(snap_points) - 1])
    translate([ snap_points[i].x, snap_points[i].y, z_pos ]) rotate(snap_points[i][2])
      cylinder(h = snap_joint_radius - gap / 2, r1 = snap_joint_radius - gap / 2,
               r2 = snap_joint_radius * 0.3, $fn = 4);
}

module snap_case_separator(intersection_gap = 0, difference_gap = 0) {
  difference() {
    translate(board_pos + [ 0, 0, -bottom_case_offset - tiny ])
      linear_extrude(bottom_case_offset + tiny * 2) offset(-intersection_gap)
        projection() hollow_shape();

    board_stops(gap = tiny);
  }

  if (!usb_port_should_be_hidden)
    translate([
      usb_port_pos.x - difference_gap,
      board_pos.y + board_size.y + back_case_gap - tiny - intersection_gap, case_pos.z -
      tiny
    ])
      cube([
        usb_port_size.x + difference_gap * 2,
        back_case_wall_thickness + tiny * 2 + intersection_gap,
        usb_port_pos.z - case_pos.z
      ]);

  if (!eth_port_should_be_hidden)
    translate([
      eth_port_pos.x - difference_gap,
      board_pos.y + board_size.y + back_case_gap - tiny - intersection_gap, case_pos.z -
      tiny
    ])
      cube([
        eth_port_size.x + difference_gap * 2,
        back_case_wall_thickness + tiny * 2 + intersection_gap,
        eth_port_pos.z - case_pos.z
      ]);

  if (wifi_antenna_accessible)
    translate([
      wifi_antenna_mount_pos.x - wifi_antenna_mount_radius - difference_gap,
      case_pos.y - tiny, case_pos.z -
      tiny
    ])
      cube([
        wifi_antenna_mount_radius * 2 + difference_gap * 2,
        front_case_wall_thickness + tiny * 2 + intersection_gap,
        wifi_antenna_mount_pos.z - case_pos.z
      ]);

  case_snaps(gap = intersection_gap);
}

module snap_case() { case_blueprint(expand_board_stops_top = true) corner_columns(); }

module snap_case_bottom_lid() {
  intersection() {
    snap_case();
    snap_case_separator(intersection_gap = case_slot_gap);
  }
}

module snap_case_top_lid() {
  difference() {
    snap_case();
    snap_case_separator(difference_gap = case_slot_gap);
  }
}

if ($preview) {
  snap_case_top_lid();
  snap_case_bottom_lid();
  % board();
}

translate([ case_size.x + 5, -board_size.y, top_case_offset ]) rotate([180])
  snap_case_top_lid();
translate([ 0, -board_size.y * 2, bottom_case_offset + board_size.z ])
  snap_case_bottom_lid();
