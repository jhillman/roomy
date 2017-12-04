package ${packageName}.database;

import ${packageName}.model.ModelTypeAdapters;

<#list entityModels as model>
  <#if model.primaryKeyMember??>
import ${packageName}.model.<#if model.package??>${model.package}.</#if>${model.name};
  </#if>
</#list>

<#list entityModels as model>
  <#if model.primaryKeyMember??>
import ${packageName}.dao.<#if model.package??>${model.package}.</#if>${model.name}Dao;
  </#if>
</#list>
 
import android.arch.persistence.room.Database;
import android.arch.persistence.room.RoomDatabase;
import android.arch.persistence.room.TypeConverter;
import android.arch.persistence.room.TypeConverters;
 
@Database(entities={ 
<#list entityModels as model>
  <#if model.primaryKeyMember??>
        ${model.name}.class,
  </#if>
</#list>
}, version=1)
@TypeConverters(ModelTypeAdapters.class)
public abstract class ${databasePrefix}Database extends RoomDatabase {
<#list entityModels as model>
  <#if model.primaryKeyMember??>
    public abstract ${model.name}Dao ${model.name?uncap_first}Dao();
  </#if>
</#list>

    // BEGIN PERSISTED SECTION - put custom methods here
    // END PERSISTED SECTION
}