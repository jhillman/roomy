package ${packageName}.model
 
import com.google.gson.Gson
import com.google.gson.GsonBuilder

import android.arch.persistence.room.TypeConverter
import com.google.gson.reflect.TypeToken

<#list types.imports as model> 
import ${model.fullPackageName}
</#list>

<#list types.enums as enum> 
import ${enum.class}
</#list>
 
@Suppress("UNCHECKED_CAST")
class ModelTypeAdapters {
    private val gson = GsonBuilder().registerTypeAdapterFactory(ModelAdapterFactory.create()).create()
<#list types.models as model> 

    @TypeConverter
    fun from${model.name}(${model.name?uncap_first}: ${model.name}?): String {
        return gson.toJson(${model.name?uncap_first})
    }

    @TypeConverter
    fun to${model.name}(${model.name?uncap_first}Json: String): ${model.name}? {
        return gson.fromJson(${model.name?uncap_first}Json, ${model.name}::class.java)
    }
</#list>
<#list types.modelLists as model> 

    @TypeConverter
    fun from${model.name}List(${model.name?uncap_first}List: List<${model.name}>?): String {
        return gson.toJson(${model.name?uncap_first}List)
    }

    @TypeConverter
    fun to${model.name}List(${model.name?uncap_first}Json: String): List<${model.name}>? {
        return gson.fromJson<Any>(${model.name?uncap_first}Json, object : TypeToken<List<${model.name}>>(){}.type) as List<${model.name}>?
    }
</#list>
<#list types.enums as enum> 

    @TypeConverter
    fun from${enum.name}(${enum.name?uncap_first}: ${enum.name}?): String? {
        return ${enum.name?uncap_first}?.name
    }

    @TypeConverter
    fun to${enum.name}List(${enum.name?uncap_first}String: String?): ${enum.name}? {
        ${enum.name?uncap_first}String?.let {
            return ${enum.name}.valueOf(it)
        }

        return null
    }
</#list>

    // BEGIN PERSISTED SECTION - put custom methods here
${persistedSection}
    // END PERSISTED SECTION
}