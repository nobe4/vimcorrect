
" Main entry point
function! s:Correct()
  let s:current_word_highlight = -1
  let s:current_word = -1

  set spell

  " Open the suggestion box
  vertical new
  vertical resize 40

  nnoremap <buffer> q :call <SID>Quit()<CR>
  nnoremap <buffer> n :call <SID>Move(']s')<CR>
  nnoremap <buffer> N :call <SID>Move('[s')<CR>
  nnoremap <buffer> <CR> :call <SID>CorrectCurrentWord()<CR>

  " Go to the first next error
  call <SID>Move(']s')
endfunction

function! s:RemoveHighlight()
  if s:current_word_highlight != -1
    call matchdelete(s:current_word_highlight)
  endif
endfunction

function! s:Quit()
  quit!
  set nospell
  call <SID>RemoveHighlight()
endfunction

" Correct the current misspelled word with the selection
function! s:CorrectCurrentWord()
  let l:correct_word = getline('.')

  execute winnr("$") . "wincmd w"

  execute 's/\%'.line('.').'l'.'\%'.col('.').'c'.s:current_word.'/'.l:correct_word

  execute "1 wincmd w"
endfunction

" Move to the next/previous mistake
function! s:Move(movement)
  " Go to original window
  execute winnr("$") . "wincmd w"

  " Move to the next/previous word to correct
  execute 'normal! '.a:movement

  " Get badly spelled word
  let l:current_word = spellbadword()

  " If there is no bad spelled word left, quit
  if len(l:current_word) == 0
    call <SID>Quit()
  endif

  " Update the current word
  let s:current_word = l:current_word[0]

  call <SID>RemoveHighlight()

  let s:current_word_highlight = matchadd('error', '\%'.line('.').'l'.'\%'.col('.').'c'.s:current_word)

  " Update the corrections display

  " Go to the suggestion window
  execute "1 wincmd w"

  " Display the suggestions
  call append(0, spellsuggest(s:current_word))

  " Remove old suggestions
  normal! dGgg
endfunction

command! Correct call <SID>Correct()
