#!/usr/bin/env python
# -*- encoding: utf-8

"""
A lint script for SaltStack SLS
"""

# Copyright (c) 2014, Hung Nguyen Viet All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

__author__ = 'Hung Nguyen Viet'
__maintainer__ = 'Hung Nguyen Viet'
__email__ = 'hvn@robotinfra.com'

import re
import sys
import os
import argparse


IGNORED_EXTS = ['patch']


class LintCheck(object):
    stable = False

    def __init__(self, paths, warn_only=False, *exts):
        self.paths = paths
        self.exts = exts
        self.warn_only = warn_only

    def run(self):
        raise NotImplementedError

    def print_header(self, content, warn_only=False):
        warn_only = warn_only or self.warn_only
        if warn_only:
            print 'WARNING: bellow lines MAYBE problems due to rule'
            print '{0!r}'.format(content)
        else:
            print 'TIPS: {0}'.format(content)
        print '-' * 10


class LintCheckTabCharacter(LintCheck):
    stable = True

    def run(self):
        '''
        Checks whether files in ``paths`` contain tab character or not.
        '''
        found = _grep(self.paths, '\t')
        if found:
            self.print_header('Must use spaces instead of tab char')
            _print_grep_result(found)
            return False
        return True


class LintCheckBadCronFilename(LintCheck):
    '''
    Check whether a state manage a cron file with filename contains ``.``
    (dot) in it because cron ignores that file.
    '''
    stable = False

    def run(self):
        exts = self.exts
        paths = self.paths
        if not exts:
            exts = ['sls']
        all_found = _grep(paths, '\/etc\/cron\.[^\/]+\/.+\.', *exts)
        filtered_found = {}
        for fn, data in all_found.iteritems():
            # no check absent SLS
            if fn.endswith('absent.sls'):
                continue
            data_without_jinja2_in_sid = {
                lino: sid for lino, sid in
                data.iteritems() if "{{" not in sid and "{%" not in sid
            }
            if data_without_jinja2_in_sid:
                for_modify = data_without_jinja2_in_sid.copy()
                for lino in data_without_jinja2_in_sid:
                    with open(fn) as f:
                        for idx, line in enumerate(f):
                            # see two lines below state ID to check if it is an
                            # absent state
                            if idx == ((lino - 1) + 2) and '- absent' in line:
                                for_modify.pop(lino)

                if for_modify:
                    filtered_found.update({fn: for_modify})

        if filtered_found:
            self.print_header('Remove the dot ``.`` in cron filename,'
                              'or cron will ignore it')
            _print_grep_result(filtered_found)
            return False
        return True


class LintCheckBadStateStyle(LintCheck):
    '''
    Checks whether files in ``paths`` use alternate style to write a state.
    It should be consistent and uses the original form.
    '''
    stable = False

    def run(self):
        exts = self.exts
        paths = self.paths

        if not exts:
            exts = ['sls']
        all_found = _grep(paths, '^  \w*\.\w*:$', *exts)
        filtered_found = {}
        for fn, data in all_found.iteritems():
            # A state ID under ``extend`` and contains ``.`` can be miss
            # understood by our regex.
            # If it's a .py file, then it will be skipped.
            # TODO find a better solution for this than just skip .py files
            # e.g. if file name is .cfg or whatever contains '.'  in its name
            # currently, this works because we only extend *.py states.
            data_without_pystates = {lino: sid for lino, sid in
                                     data.iteritems()
                                     if not sid.endswith('.py:')
                                     and not sid.endswith('.conf:')}
            if data_without_pystates:
                filtered_found.update({fn: data_without_pystates})

        if filtered_found:
            self.print_header("Use \nstate:\n  - function\nstyle instead")
            _print_grep_result(filtered_found)
            return False
        return True


class LintCheckNumbersOfOrderLast(LintCheck):
    '''
    Checks whether files in ``paths`` contain multiple lines of
    '- order: last' or not. A SLS file should only contain one.
    '''
    stable = True

    def run(self):
        exts = self.exts
        paths = self.paths
        if not exts:
            exts = ['jinja2', 'sls']
        found = _grep(paths, '- order: last', *exts)
        many_last = {k: v for k, v in found.iteritems() if len(v) > 1}

        if many_last:
            self.print_header(
                "Only one '- order: last' takes effect, use only one"
                " of that and replace other with explicit requirement"
                " (you may want to require ``sls: sls_file`` instead)"
            )
            _print_grep_result(many_last)
            return False
        return True


class CheckPillarStyleBase(LintCheck):
    '''
    Base class for check pillar style.
    '''
    stable = False

    def __init__(self, patterns, rule, *args, **kwargs):
        super(CheckPillarStyleBase, self).__init__(*args, **kwargs)
        self.patterns = patterns
        self.rule = rule

    def run(self):
        if not self.exts:
            self.exts = ['jinja2', 'sls']

        paths = _filter_files_with_exts(self.paths, self.exts)
        all_found = {}
        for path in paths:
            found = {}
            with open(path) as f:
                for idx, line in enumerate(f):
                    if 'pillar' in line:
                        line = line.replace('"', "'")
                        for pt in self.patterns:
                            if re.findall(pt, line):
                                found.update({idx + 1: line.strip('\n')})

            if found:
                all_found[path] = found

        if all_found:
            self.print_header(self.rule)
            _print_grep_result(all_found)
            return False
        return True


class LintCheckPillarStyle(CheckPillarStyleBase):
    '''
    Check bad using of pillar. Only ``salt['pillar.get']`` is allowed.
    '''
    stable = True

    def __init__(self, *args, **kwargs):
        rule = "only form salt['pillar.get'](...) is allowed"
        patterns = (" pillar\[", "in pillar[^a-zA-Z_0-9]", )
        super(LintCheckPillarStyle, self).__init__(
            patterns, rule, *args, **kwargs
        )


class LintCheckSubkeyInSaltPillar(CheckPillarStyleBase):
    '''
    Check bad using check ``if subkey in salt['pillar.get']``
    '''
    def __init__(self, *args, **kwargs):
        patterns = ("if\s+[^ ]+\s*[a-z]*\s+in\s+salt\['pillar.get'\]", )
        rule = ("do not check if subkey in salt['pillar.get']('key'), use "
                "salt['pillar.get']('key:subkey') instead.")
        super(LintCheckSubkeyInSaltPillar, self).__init__(
            patterns, rule, *args, **kwargs
        )


def _filter_files_with_exts(paths, exts):
    return set(filter(lambda p: any(p.endswith('.' + e) for e in exts), paths))


def _grep(paths, pattern, *exts):
    '''
    A function that acts like ``grep`` command line tool, but simpler

    paths
        filenames to grep on

    pattern
        regex pattern

    exts
        list of file extensions that grep will only work on
    '''
    all_found = {}
    repat = re.compile(pattern)

    def _grep_file(filename):
        found = {}
        with open(filename, 'rt') as f:
            for idx, line in enumerate(f):
                if repat.findall(line):
                    # idx count from 0, line number count from 1
                    found.update({idx + 1: line.strip('\n')})
        return found

    if exts:
        paths = _filter_files_with_exts(paths, exts)

    for path in paths:
        found = _grep_file(path)
        if found:
            all_found[path] = found

    return all_found


def _print_grep_result(all_found):
    for fn in all_found:
        print 'In file: {0}'.format(fn)
        for line, content in all_found[fn].iteritems():
            print ' line {0}: {1}'.format(line, content)


def _is_binary_file(fn):
    '''
    Check if ``fn`` is binary file.
    '''

    def _is_binary_string(bytes_):
        '''
        A hack to determine whether input string is binary or not base on
        file utility behavior.

        http://stackoverflow.com/a/7392391/807703
        '''
        textchars = (bytearray([7, 8, 9, 10, 12, 13, 27]) +
                     bytearray(range(0x20, 0x100)))
        return bool(bytes_.translate(None, textchars))

    with open(fn, 'rb') as f:
        return _is_binary_string(f.read(1024))


def _parse_paths(raw_paths):
    argdirs = []
    paths = []

    for i in raw_paths:
        if os.path.isdir(i):
            argdirs.append(i)
        elif os.path.isfile(i) and not _is_binary_file(i):
            paths.append(i)
        else:
            print 'Bad argument: {0} is not a directory or text file'.format(i)
            sys.exit(1)

    for argdir in argdirs:
        _paths = []
        for root, dirs, fns in os.walk(argdir):
            # skip dot files / dirs
            fns = [f for f in fns if not f[0] == '.']
            dirs[:] = [d for d in dirs if not d[0] == '.']
            for fn in fns:
                path = os.path.join(root, fn)
                if not _is_binary_file(path):
                    _paths.append(path)
        paths.extend(_paths)

    return set(paths) - _filter_files_with_exts(paths, IGNORED_EXTS)


def main():
    argp = argparse.ArgumentParser()
    argp.add_argument('--tabonly', '-t', action='store_true',
                      help='only run lint check for tab character')
    argp.add_argument('--stable', '-s', action='store_true',
                      help='only run lint checks that considered stable')
    argp.add_argument('--warn-nonstable', '-w', action='store_true',
                      help='only print warning messages for non stable checks'
                      ' always treat their results as passed checks')
    argp.add_argument('paths', nargs='*', default=['.'],
                      help='paths to check lint')
    args = argp.parse_args()

    paths = _parse_paths(args.paths)

    all_lints = (LintCheckTabCharacter,
                 LintCheckBadCronFilename,
                 LintCheckBadStateStyle,
                 LintCheckNumbersOfOrderLast,
                 LintCheckPillarStyle,
                 LintCheckSubkeyInSaltPillar,
                 )

    if args.stable:
        all_lints = filter(lambda x: x.stable, all_lints)
    elif args.tabonly:
        all_lints = (LintCheckTabCharacter)

    res = []
    for lint in all_lints:
        if lint.stable:
            res.append(lint(paths, args.warn_nonstable).run())
        else:
            if args.warn_nonstable:
                lint(paths, warn_only=True).run()
                res.append(True)
            else:
                res.append(lint(paths, args.warn_nonstable).run())

    no_of_false = res.count(False)

    print '\nTotal checks: {0}, total failures: {1}'.format(len(res),
                                                            no_of_false)
    sys.exit(no_of_false)


# TODO: lint check for pip.installed usage - it needs to check 2 continue lines
if __name__ == "__main__":
    main()
