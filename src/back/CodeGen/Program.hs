{-# LANGUAGE MultiParamTypeClasses, FlexibleInstances, NamedFieldPuns #-}

{-| Translate an Encore program (see "AST") into a tuple
@(classes, header, shared)@, where @classes@ is a list of the
translated classes (one file per class) together with their names,
@header@ is the common header file of all the classes, and
@shared@ is the code for the file of shared C code. Each C file
(value of type @CCode FIN@) can be pretty-printed (see
"CCode.PrettyCCode"), and a C compiler might be able to compile
the result.-}

module CodeGen.Program(translate) where

import CodeGen.Typeclasses
import CodeGen.ClassDecl
import CodeGen.CCodeNames
import CodeGen.Header
import CodeGen.Shared
import CodeGen.ClassTable
import qualified CodeGen.Context as Ctx

import CCode.Main
import qualified AST.AST as A
import qualified Types as Ty
import Control.Monad.Reader hiding (void)
import qualified CodeGen.Context as Ctx

instance Translatable A.Program ([(String, CCode FIN)], CCode FIN, CCode FIN) where
    translate prog@(A.Program{A.imports, A.classes}) = (classList, header, shared)
        where
          -- recursively translate the programs in the imports DONE, but nothing done with them
          -- compile local stuff using new class table
          -- do something with shared (probably one shared)
          ctable = build_class_table prog   -- builds it recursively

          header = generate_header prog     -- generates it recursively

          shared = generate_shared prog ctable
          
          --  TODO: DELETE classList = translate_recurser prog ctable
          
          classList = A.traverseProgram f g prog
            where
                name_and_class cdecl@(A.Class{A.cname}) = (Ty.getId cname, translate cdecl ctable)
                f prog@(A.Program{A.classes}) = map name_and_class classes
                g a b = a ++ concat b
  
{- TODO: DELETE
translate_recurser prog@(A.Program{A.imports, A.classes}) ctable = classList
    where
          classList = map name_and_class classes ++ concat (map translate_import imports)

          -- local functions
          translate_import (A.PulledImport{A.iprogram}) = translate_recurser iprogram ctable
          name_and_class cdecl@(A.Class{A.cname}) = (Ty.getId cname, translate cdecl ctable)
-}

