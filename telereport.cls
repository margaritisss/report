% telereport.cls -- LaTeX port of the Typst template @preview/telereport:0.1.0
% Unofficial Télécom Paris report layout (cover page, header, footer, headings).

\NeedsTeXFormat{LaTeX2e}                          % refuse to run on ancient LaTeX
\ifdefined\pdfminorversion\pdfminorversion=7\fi        % accept the PDF 1.7 logos (pdfLaTeX defaults to 1.5)
\ProvidesClass{telereport}[2026/09/19 Unofficial Telecom Paris report]  % class id + version

% ---------------------------------------------------------------- options
\newcommand{\tp@lang}{english}                    % default language, like lang: "en"
\DeclareOption{en}{\renewcommand{\tp@lang}{english}}  % \documentclass[en]{telereport}
\DeclareOption{fr}{\renewcommand{\tp@lang}{french}}   % \documentclass[fr]{telereport}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}  % anything else goes to article
\ProcessOptions\relax                             % apply the options chosen by the user
\LoadClass[11pt,a4paper]{article}                 % Typst default: 11pt text on A4

% ---------------------------------------------------------------- packages
\RequirePackage[T1]{fontenc}                      % proper accents (é, è) in the PDF
\RequirePackage[utf8]{inputenc}                   % accept UTF-8 source files
\RequirePackage[\tp@lang]{babel}                  % hyphenation + language rules
\RequirePackage[scaled=0.92]{helvet}              % Arial look-alike (template font: "Arial")
\renewcommand{\familydefault}{\sfdefault}         % make the sans font the body font
\RequirePackage{geometry}                         % page margins
\RequirePackage{xcolor}                           % brand colours
\RequirePackage{graphicx}                         % logos
\RequirePackage{tikz}                             % cover page drawing + small bars
\RequirePackage{fancyhdr}                         % custom header and footer
\RequirePackage{titlesec}                         % custom heading style
\RequirePackage{lastpage}                         % total page count for "2 / 7"
\RequirePackage{etoolbox}                         % list helpers for authors/supervisors
\RequirePackage[hidelinks]{hyperref}              % clickable mailto links, no ugly boxes

% ---------------------------------------------------------------- colours
\definecolor{tpred}{HTML}{BF1238}                 % Télécom Paris red (tp-red)
\definecolor{tpgrey}{gray}{0.30}                  % luma(30%) (tp-grey)
\definecolor{tpmail}{gray}{0.39}                  % luma(100) used for e-mails

% ---------------------------------------------------------------- translations
\newcommand{\tp@abstractname}{Abstract}           % English defaults...
\newcommand{\tp@supervisionname}{Under the supervision of}
\newcommand{\tp@keywordsname}{Keywords}
\ifdefstring{\tp@lang}{french}{%                  % ...swapped when [fr] is given
  \renewcommand{\tp@abstractname}{Résumé}%
  \renewcommand{\tp@supervisionname}{Sous la supervision de}%
  \renewcommand{\tp@keywordsname}{Mots-clés}%
}{}

% ---------------------------------------------------------------- user fields
\newcommand{\tp@title}{}                          % filled by \title
\newcommand{\tp@shorttitle}{}                     % filled by \shorttitle
\newcommand{\tp@subtitle}{}                       % filled by \subtitle
\newcommand{\tp@date}{}                           % filled by \date
\newcommand{\tp@sidebar}{}                        % filled by \sidebartext
\newcommand{\tp@keywords}{}                       % filled by \keywords
\newcommand{\tp@abstract}{}                       % filled by the abstract environment
\newif\iftp@logo \tp@logotrue                     % logo: true
\newif\iftp@showmail \tp@showmailfalse            % show-mail: false
\newif\iftp@coloredbar \tp@coloredbartrue         % show-colored-bar: true

\renewcommand{\title}[1]{\renewcommand{\tp@title}{#1}}               % main title
\newcommand{\shorttitle}[1]{\renewcommand{\tp@shorttitle}{#1}}       % header title
\newcommand{\subtitle}[1]{\renewcommand{\tp@subtitle}{#1}}           % cover subtitle
\renewcommand{\date}[1]{\renewcommand{\tp@date}{#1}}                 % date under the cover
\newcommand{\sidebartext}[1]{\renewcommand{\tp@sidebar}{#1}}         % vertical red-bar text
\newcommand{\keywords}[1]{\renewcommand{\tp@keywords}{#1}}           % comma-separated list
\newcommand{\showmail}{\tp@showmailtrue}                             % show-mail: true
\newcommand{\nologo}{\tp@logofalse}                                  % logo: false
\newcommand{\nocoloredbar}{\tp@coloredbarfalse}                      % show-colored-bar: false
\renewenvironment{abstract}{\tp@grababs}{} % store, don't print
\long\def\tp@grababs#1\end{\gdef\tp@abstract{#1}\end}                % grab body up to \end

% ---------------------------------------------------------------- people
\newcommand{\tp@authors}{}                        % accumulated author blocks
\newcommand{\tp@supervisors}{}                    % accumulated supervisor blocks

% One person: name (linked if mail given) + optional grey e-mail line.
\newcommand{\tp@person}[2]{%
  \begin{minipage}[t]{0.48\linewidth}\centering  % half the width -> two per row
    \ifstrempty{#2}{#1}{\href{mailto:#2}{#1}}%    % name, clickable when mail exists
    \iftp@showmail\ifstrempty{#2}{}{%             % e-mail only if show-mail is on
      \\[0.2em]{\small\color{tpmail}\href{mailto:#2}{#2}}}\fi%
  \end{minipage}%
}
\newcommand{\addauthor}[2]{\gappto\tp@authors{\tp@person{#1}{#2}\allowbreak}}         % \addauthor{Name}{mail}
\newcommand{\addsupervisor}[2]{\gappto\tp@supervisors{\tp@person{#1}{#2}\allowbreak}} % same for supervisors

% ---------------------------------------------------------------- page layout
\geometry{top=3.5cm, bottom=2.5cm, left=2.5cm, right=2.5cm}  % content margins from Typst
\geometry{headheight=2.2cm, headsep=0.4cm}         % tall header to fit the 2cm logo
\setlength{\parindent}{0pt}                       % Typst paragraphs are not indented
\setlength{\parskip}{0.65em}                      % ...they are separated by space instead
\newcommand{\tp@logoV}{assets/Logo_Telecom_IPParis_RVB_noir_V} % vertical logo (header)
\newcommand{\tp@logoH}{assets/Logo_Telecom_IPParis_RVB_noir_H} % horizontal logo (cover)
\newsavebox{\tp@headlogo}                         % measure the logo once
\sbox{\tp@headlogo}{\includegraphics[height=2cm]{\tp@logoV}}  % header logo, 2cm tall

\pagestyle{fancy}                                 % use our header/footer everywhere
\fancyhf{}                                        % clear article's defaults
\renewcommand{\headrulewidth}{0pt}                % we draw our own rule
\renewcommand{\sectionmark}[1]{\markboth{#1}{}}   % header shows the plain section name

% Header: [short title ........ current section]  [logo]
%         [------------------ grey rule ----------]
\newcommand{\tp@headtext}{\ifdefempty{\tp@shorttitle}{\tp@title}{\tp@shorttitle}}  % fallback to title
\fancyhead[C]{%
  \iftp@logo\setlength{\dimen0}{\dimexpr\headwidth-\wd\tp@headlogo-1.5em}%  % leave room for logo
  \else\setlength{\dimen0}{\headwidth}\fi%        % full width when no logo
  \begin{minipage}[c]{\dimen0}\small\color{tpgrey}%
    \parbox[b]{0.65\linewidth}{\raggedright\tp@headtext}\hfill\leftmark\\[0.3em]  % title | section
    {\color{tpgrey}\rule{\linewidth}{0.5pt}}%     % thin grey line under it
  \end{minipage}%
  \iftp@logo\hspace{1.5em}\raisebox{-0.5\height}{\usebox{\tp@headlogo}}\fi%  % logo on the right
}

% Footer: red bold "page / total" + three coloured blocks near the page edge.
\fancyfoot[C]{%
  {\color{tpred}\bfseries\thepage\ / \pageref{LastPage}}%  % e.g. 2 / 7
  \iftp@coloredbar\begin{tikzpicture}[remember picture, overlay]  % draw relative to the page
    \fill[tpgrey] ([xshift=-1.5cm,yshift=0.65cm]current page.south) rectangle ++(1cm,0.3cm);
    \fill[black]  ([xshift=-0.5cm,yshift=0.65cm]current page.south) rectangle ++(1cm,0.3cm);
    \fill[tpred]  ([xshift= 0.5cm,yshift=0.65cm]current page.south) rectangle ++(1cm,0.3cm);
  \end{tikzpicture}\fi%
}

% ---------------------------------------------------------------- headings
% One "barette": three stacked 2pt-wide bars, grey / black / red from top to bottom.
\newcommand{\tp@barette}{%
  \tikz[baseline=0.135em]{%                       % sink it 15% below the baseline
    \fill[tpgrey] (0,0.6em) rectangle (2pt,0.9em);% top bar
    \fill[black]  (0,0.3em) rectangle (2pt,0.6em);% middle bar
    \fill[tpred]  (0,0)     rectangle (2pt,0.3em);% bottom bar
  }%
}
\newcommand{\tp@barettes}[1]{%                    % repeat once per heading level
  \tp@barette\ifnum#1>1\hspace{0.2em}\tp@barette\fi\ifnum#1>2\hspace{0.2em}\tp@barette\fi%
  \hspace{0.3em}%                                 % gap before the heading text
}
\newcommand{\tp@semibold}{\bfseries}  % template asks for semibold; Helvetica only has bold
\titleformat{\section}{\Large\tp@semibold}{\tp@barettes{1}\thesection}{0.5em}{}
\titleformat{\subsection}{\large\tp@semibold}{\tp@barettes{2}\thesubsection}{0.5em}{}
\titleformat{\subsubsection}{\normalsize\tp@semibold}{\tp@barettes{3}\thesubsubsection}{0.5em}{}
% titlesec drops the label when unnumbered, so keep the bars in a "before code" instead:
\titleformat{name=\section,numberless}{\Large\tp@semibold}{}{0pt}{\tp@barettes{1}}
\titleformat{name=\subsection,numberless}{\large\tp@semibold}{}{0pt}{\tp@barettes{2}}
\titleformat{name=\subsubsection,numberless}{\normalsize\tp@semibold}{}{0pt}{\tp@barettes{3}}
\titlespacing*{\section}{0pt}{1.25em}{1em}        % above: 1.25em, below: 1em
\titlespacing*{\subsection}{0pt}{1.25em}{1em}     % same for every level
\titlespacing*{\subsubsection}{0pt}{1.25em}{1em}
\setcounter{secnumdepth}{0}                       % Typst template has no numbers; set 3 to enable

% ---------------------------------------------------------------- cover page
\renewcommand{\maketitle}{%
  \begin{titlepage}                               % own page, no header/footer
  \begin{tikzpicture}[remember picture, overlay]  % draw in absolute page coordinates
    % left red sidebar, 2.5cm wide, full height
    \fill[tpred] (current page.south west) rectangle ([xshift=2.5cm]current page.north west);
    % vertical sidebar text, reading bottom-to-top, starting 2cm above the bottom
    \node[rotate=90, anchor=west, text=white, font=\bfseries\LARGE]
      at ([xshift=1.25cm, yshift=2cm]current page.south west) {\textsc{\tp@sidebar}};
    % logo in the top-left corner of the white area (1cm padding)
    \iftp@logo
      \node[anchor=north west, inner sep=0]
        at ([xshift=3.5cm, yshift=-1cm]current page.north west)
        {\includegraphics[height=3cm]{\tp@logoH}};
    \fi
    % all the text, centred in the white area (page width minus sidebar minus 2x1cm padding)
    \node[anchor=center, text width=\dimexpr\paperwidth-4.5cm\relax, align=center]
      at ([xshift=1.25cm]current page.center) {\tp@covercontent};
    % date near the bottom, grey
    \node[anchor=south, font=\large, text=tpgrey]
      at ([xshift=1.25cm, yshift=2cm]current page.south) {\tp@date};
  \end{tikzpicture}
  \end{titlepage}
  \setcounter{page}{2}                            % cover counts as page 1, like in Typst
}

% The centred cover content, grouped exactly like the Typst version.
\newcommand{\tp@covercontent}{%
  {\fontsize{27.5}{33}\selectfont\bfseries\tp@title\par}%          % title, 2.5em
  \ifdefempty{\tp@subtitle}{}{\vspace{1.5em}%
    {\fontsize{16.5}{20}\selectfont\color{tpgrey}\tp@subtitle\par}}%  % subtitle, 1.5em grey
  \vspace{4em}%                                   % gap between groups
  \ifdefempty{\tp@authors}{}{%
    {\fontsize{13.2}{17}\selectfont\tp@authors\par}}%             % authors, 1.2em
  \ifdefempty{\tp@supervisors}{}{\vspace{4em}%
    {\fontsize{12.1}{16}\selectfont\textit{\tp@supervisionname}\par\vspace{0.5em}%
     \tp@supervisors\par}}%                                       % supervisors, 1.1em
  \vspace{4em}%
  \ifdefempty{\tp@abstract}{}{%
    \begin{minipage}{0.9\linewidth}%              % abstract block, 90% wide
      \centering\textbf{\tp@abstractname}\par     % bold centred heading
      \justifying\tp@abstract\par                 % justified body
    \end{minipage}\par\vspace{1.5em}}%
  \ifdefempty{\tp@keywords}{}{%
    \textbf{\tp@keywordsname:} \tp@keywords\par}% % "Keywords: a, b, c"
}
\providecommand{\justifying}{\rightskip=0pt \leftskip=0pt \parfillskip=0pt plus 1fil}  % undo centering

\endinput