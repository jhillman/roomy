package ${packageName}.database

import ${packageName}.model.ModelTypeAdapters

<#list entityModels as model>
  <#if model.primaryKeyMember??>
import ${packageName}.model.<#if model.package??>${model.package}.</#if>${model.name}
  </#if>
</#list>

<#list entityModels as model>
  <#if model.primaryKeyMember??>
import ${packageName}.dao.<#if model.package??>${model.package}.</#if>${model.name}Dao
  </#if>
</#list>
 
import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters

/**
* AUTO-GENERATED CLASS.
* Make changes in <code>room.json</code> or use <code>PERSISTED SECTION</code> below
*/
 
@Database(entities = arrayOf( 
<#list entityModels as model>
        ${model.name}::class<#sep>,</#sep>
</#list>
), version = ${databaseVersion})
@TypeConverters(ModelTypeAdapters::class)
abstract class ${databasePrefix}Database : RoomDatabase() {
<#list entityModels as model>
    abstract fun ${model.name?uncap_first}Dao() : ${model.name}Dao 
</#list>

    fun deleteAll() {
<#list entityModels as model>
        ${model.name?uncap_first}Dao().deleteAll()
</#list>
    }

    // BEGIN PERSISTED SECTION - put custom methods here
${persistedSection}
    // END PERSISTED SECTION
}