package com.chatbooks.injection

import com.chatbooks.Chatbooks
<#list entityModels as model>
  <#if model.primaryKeyMember??>
import ${packageName}.dao.<#if model.package??>${model.package}.</#if>${model.name}Dao
  </#if>
</#list>
import ${packageName}.database.${databasePrefix}Database
import dagger.Module
import dagger.Provides
import javax.inject.Singleton

/**
* AUTO-GENERATED CLASS.
* Make changes in <code>room.json</code> or use <code>PERSISTED SECTION</code> below
*/
 
@Module
class DaggerDaoModule {

  <#list entityModels as model>
  @Provides
  @Singleton
  internal fun provide${model.name}Dao(database: ${databasePrefix}Database): ${model.name}Dao {
      return database.${model.name?uncap_first}Dao()
  }
  </#list>

  // BEGIN PERSISTED SECTION - put custom methods here
${persistedSection}
  // END PERSISTED SECTION
}