module Main where

import Extra
import Hakyll

data Link = Link {url :: String, desc :: String, relMe :: Bool}

links :: [Link]
links =
  [ Link "https://plasmatrap.com/@syn" "fedi" True,
    Link "https://github.com/synthetica9" "github" False,
    Link "https://last.fm/user/synthetica9" "last.fm" False,
    Link "https://traewelling.de/@syn" "träwelling" False
  ]

-- TODO: FA icons or similar
renderLink :: Link -> String
renderLink link =
  "<a href=\""
    <> link.url
    <> "\""
    <> mwhen link.relMe " rel=\"me\" "
    <> ">"
    <> escapeHtml link.desc
    <> "</a>"

linkBlock :: String
linkBlock =
  let aElems = renderLink <$> links
      liElems = (\x -> "<li>" <> x <> "</li>") <$> aElems
   in "<ul>" <> concat liElems <> "</ul>"

mainContext = constField "links" linkBlock <> defaultContext

main :: IO ()
main = hakyll $ do
  match "templates/*" $ compile templateCompiler

  match "index.html" $ do
    route idRoute
    let indexContext = constField "title" "home" <> mainContext

    compile $ do
      getResourceBody
        >>= applyAsTemplate indexContext
        >>= loadAndApplyTemplate "templates/default.html" indexContext
        >>= relativizeUrls
