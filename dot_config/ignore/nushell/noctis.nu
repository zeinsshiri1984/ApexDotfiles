# Noctis Theme for Nushell
# Reference: https://github.com/liviuschera/noctis

let noctis_theme = {
    # Syntax
    separator: "#df769b" # Keywords/Operators color (Pale Violet Red)
    leading_trailing_space_bg: { attr: "n" }
    header: { fg: "#16b673" attr: "b" } # Mountain Meadow (Interpolated Strings - green-ish)
    empty: "#5b858b" # Horizon (Comments - blue-grey)
    bool: "#7060eb" # Cornflower Blue (Numbers & Booleans)
    int: "#7060eb"
    filesize: "#7060eb"
    duration: "#7060eb"
    date: "#7060eb"
    range: "#7060eb"
    float: "#7060eb"
    string: "#49e9a6" # Eucalyptus (Strings)
    nothing: "#5b858b"
    binary: "#7060eb"
    cell-path: "#df769b"
    row_index: { fg: "#16b673" attr: "b" }
    record: "#49d6e9" # Turcoise (Method Calls)
    list: "#49d6e9"
    block: "#df769b"
    hints: "#5b858b"
    search_result: { bg: "#e66533" fg: "#ffffff" } # Cinnabar (Function/Var decl)

    # Shape
    shape_and: { fg: "#df769b" attr: "b" }
    shape_binary: { fg: "#df769b" attr: "b" }
    shape_block: { fg: "#16a3b6" attr: "b" } # Eastern Blue (Function Calls)
    shape_bool: "#7060eb"
    shape_closure: { fg: "#16a3b6" attr: "b" }
    shape_custom: "#49e9a6"
    shape_datetime: "#7060eb"
    shape_directory: "#49d6e9"
    shape_external: "#49d6e9"
    shape_externalarg: "#e4b781" # Gold Sand (Variables & Parameters)
    shape_filepath: "#49d6e9"
    shape_flag: { fg: "#d67e5c" attr: "b" } # Japonica (Object properties)
    shape_float: "#7060eb"
    shape_garbage: { fg: "#FFFFFF" bg: "#FF0000" attr: "b" }
    shape_globpattern: { fg: "#49d6e9" attr: "b" }
    shape_int: { fg: "#7060eb" attr: "b" }
    shape_internalcall: { fg: "#16a3b6" attr: "b" }
    shape_keyword: { fg: "#df769b" attr: "b" }
    shape_list: { fg: "#49d6e9" attr: "b" }
    shape_literal: "#49e9a6"
    shape_match_pattern: "#16b673"
    shape_matching_brackets: { attr: "u" }
    shape_nothing: "#5b858b"
    shape_operator: "#df769b"
    shape_or: { fg: "#df769b" attr: "b" }
    shape_pipe: { fg: "#df769b" attr: "b" }
    shape_range: { fg: "#e4b781" attr: "b" }
    shape_record: { fg: "#49d6e9" attr: "b" }
    shape_redirection: { fg: "#df769b" attr: "b" }
    shape_signature: { fg: "#16b673" attr: "b" }
    shape_string: "#49e9a6"
    shape_string_interpolation: { fg: "#16b673" attr: "b" }
    shape_table: { fg: "#16a3b6" attr: "b" }
    shape_variable: "#e4b781"
    shape_vardecl: "#e66533"
}

$env.config.color_config = $noctis_theme
