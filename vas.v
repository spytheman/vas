module main

import os
import flag
import parser
import elf

fn file_name_without_ext(file_name string) string {
	ext_len := os.file_ext(file_name).len
	bytes := file_name.bytes()
	return bytes[..bytes.len - ext_len].bytestr()
}

fn main() {
	mut fp := flag.new_flag_parser(os.args)
    fp.application('vas')
    fp.version('v0.0.0')
    fp.skip_executable()
    mut out_file := fp.string('o', `o`, 'out_file_none', 'set output file name')

    additional_args := fp.finalize() or {
        println(fp.usage())
        return
    }

	if additional_args.len < 1 {
		println(fp.usage())
        return
	}

	file_name := additional_args[0]

	if out_file == 'out_file_none' {
		out_file = file_name_without_ext(file_name) + '.o'
	}

	program := os.read_file(file_name) or {
		eprintln('error: reading file `${file_name}`')
		exit(1)
	}

	mut p := parser.new(program, file_name)
	p.parse()

	// add index to instructions
	for i := 0; i < p.instrs.len; i++ {
		p.instrs[i].index = i
	}

	for p.variable_instrs.len > 0 {
		p.variable_instrs = p.resolve_variable_length_instrs(mut p.variable_instrs)
	}

	mut e := elf.new(out_file)

	e.assign_addresses_and_set_bindings(mut p.instrs, mut p.defined_symbols)
	e.resolve_call_targets(p.call_targets)
	e.rela_text_users(p.rela_text_users)
	e.elf_symtab_strtab()
	e.elf_rest()
	e.write_elf()
}

