
| дата начала         |     дата конца      | длительность | исполнитель  |  
|:-------------------:|:-------------------:|:------------:|:------------:|  
| 2021y-06m-24d 23:30 | 2021y-06m-24d 23:50 |    20 min    | Kartonagnick |  

[ссылка на историю](../history.md/#v002)  

#8-principles
=============

В этой задаче необходимо сформулировать фундаментальный закон разработки:  
  - **История не знает сослагательного наклонения**  

Из этого фундаментального закона вытекает:  
  - История движется только вперед.  
  - Нельзя вернуться в прошлое, и всё исправить.  
  - Нельзя изменить содержимое мерж-коммита.  
  - Можно признать версию забагованной, 
    и выпустить исправление.  

--------------------------------------------------------------------------------

Мы не подтасовываем историю:  
  - Не пытаемся изменять старые коммиты в мастере.  

--------------------------------------------------------------------------------

Мы не пересоздаем репозиторий.  
Потому что уничтожение репозитория влечет за собой удаление связанных с ним `контрибуций`  
  - `констрибуция` - это вклад в развитие аккаунта на [github][CONTRIB]  

Историю репозитория можно сбросить с помощью команды `reset`  
Но нужно подумать дважды, прежде чем решиться на такой шаг:  
  - `reset` полностью уничтожает часть истории проекта.  
  - позволяет удалить часть коммитов.
  - счетчики `ID-задач` при этом не сбрасываются.  

Выполнять `reset` имеет смысл только для молодых проектов,  
развитие которых зашло в тупик.  

Нельзя уничтожать историю от которой уже зависят клиенты.  

--------------------------------------------------------------------------------

План работ:
  - [x] добавляем ссылку на титульную  страницу.  


[CONTRIB]: https://docs.github.com/en/github/setting-up-and-managing-your-github-profile/managing-contribution-graphs-on-your-profile/why-are-my-contributions-not-showing-up-on-my-profile
  "Learn how we count contributions"