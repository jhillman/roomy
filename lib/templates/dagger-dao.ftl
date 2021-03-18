package com.chatbooks.injection

<#list entityModels as model>
  <#if model.primaryKeyMember??>
import ${packageName}.dao.<#if model.package??>${model.package}.</#if>${model.name}Dao
  </#if>
</#list>
import ${packageName}.database.${databasePrefix}Database
import dagger.Module
import dagger.Provides
import javax.inject.Singleton
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent

/**
* AUTO-GENERATED CLASS.
* Make changes in <code>room.json</code> or use <code>PERSISTED SECTION</code> below
*/
 
@Module
@InstallIn(SingletonComponent::class)
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