#   ;,//;,    ,;/
#  o:::::::;;///
# >::::::::;;\\\
#   ''\\\\\'" ';\

set -U fish_greeting ''

set -gx EDITOR nano
set -gx VISUAL code
set -gx RUSTC_WRAPPER sccache

# paths
fish_add_path ~/.local/bin
fish_add_path ~/go/bin
fish_add_path ~/flutter/bin
fish_add_path ~/.cargo/bin

# shell config
if status is-interactive

    # load plugins
    # ------------

    # better prompt
    if type -q starship
        starship init fish | source
    end

    # better cd
    if type -q zoxide
        zoxide init fish | source
    end

    # faster node manager
    if type -q fnm
        fnm env --use-on-cd | source
    end

    # history
    if type -q atuin
        atuin init fish | source
    end

    # abbreviations
    # -------------

    abbr --add .. 'cd ..'
    abbr --add ... 'cd ../..'
    abbr --add .3 'cd ../../..'

    # better ls
    if type -q eza
        abbr --add ls 'eza --icons --group-directories-first'
        abbr --add ll 'eza -al --icons --group-directories-first'
        abbr --add lt 'eza -aT --icons --group-directories-first' # Tree view
    end

    # better cat
    if type -q bat
        abbr --add cat 'bat'
    end

    # git
    abbr --add gs 'git status'
    abbr --add stash 'git stash -u'

    # clipboard
    abbr --add clipboard 'xsel -ib'

    # pnpm
    abbr --add pp 'pnpm'

    # shutdown now
    abbr --add nuke 'shutdown now'

    # functions
    # ---------

    function cl
        cd $argv[1]
        eza --icons --group-directories-first
    end

    function sail
        if test -f sail
            sh sail $argv
        elseif test -f vendor/bin/sail
            sh vendor/bin/sail $argv
        else
            echo "No sail script found."
        end
    end

end

# pnpm
set -gx PNPM_HOME "/home/sem/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
