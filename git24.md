#git24

**1. Найдите полный хеш и комментарий коммита, хеш которого начинается на aefea.**  
`$ git log aefea -n 1`  
 aefead2207ef7e2aa5dc81a34aedf0cad4c32545  
 Update CHANGELOG.md
   
**2. Какому тегу соответствует коммит 85024d3?**  
`git log 85024d3 --oneline -n 1`  
tag: v0.12.23
   
**3. Сколько родителей у коммита b8d720? Напишите их хеши.**  
 `git log b8d720 -n 1`  
2 родителя  
56cd7859e   
9ea88f22f
   
**4. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами v0.12.23 и v0.12.24.**  
`git log v0.12.22..v0.12.24 --oneline`  
b14b74c49 [Website] vmc provider links  
3f235065b Update CHANGELOG.md  
6ae64e247 registry: Fix panic when server is unreachable  
5c619ca1b website: Remove links to the getting started guide's old location  
06275647e Update CHANGELOG.md  
d5f9411f5 command: Fix bug when using terraform login on Windows  
4b6d06cc5 Update CHANGELOG.md  
dd01a3507 Update CHANGELOG.md  
225466bc3 Cleanup after v0.12.23 release 
   
**5. Найдите коммит в котором была создана функция func providerSource.**  
`$ git log -S "func providerSource" -p --reverse`  
8c928e83589d90a031f811fae52a81be7153e82f  
   
**6. Найдите все коммиты в которых была изменена функция globalPluginDirs.**  
`git log -S "func globalPluginDirs" -p --reverse`  
8364383c359a6b738a436d1b7745ccdce178df47
   
**7. Кто автор функции synchronizedWriters?**  
`git log -S "func synchronizedWriters" --reverse`  
Author: Martin Atkins <mart@degeneration.co.uk>


   

   
